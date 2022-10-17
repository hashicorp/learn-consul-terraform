package main

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
)

// ErrNotFound is returned when a database operation is successful but the requested resource
// does not exist.
var ErrNotFound = fmt.Errorf("not found")

// CoffeeDB is a PostreSQL implementation of a persistent Coffee data store.
type CoffeeDB struct {
	conn *pgx.Conn
}

// NewCoffeeDB returns a new instance of a CoffeeDB.
// It pulls its connection details from environment variables
// and opens a connection to the Postgres database.
// It returns a non-nil error if the operation fails.
//
// The following environment variables are used to establish the connection:
//
//	PGDATABASE
//	PGHOST
//	PGPASSWORD
//	PGPORT
//	PGUSER
func NewCoffeeDB(ctx context.Context) (*CoffeeDB, error) {
	conn, err := pgx.Connect(ctx, "")
	if err != nil {
		return nil, err
	}
	return &CoffeeDB{conn: conn}, nil
}

const (
	deleteCoffee      = `DELETE FROM coffees WHERE id=$1`
	deleteIngredients = `DELETE FROM coffee_ingredients WHERE coffee_id=$1`
	insertCoffee      = `INSERT INTO coffees (name, teaser, collection, origin, color, description, price, image, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);`
	insertIngredient  = `INSERT INTO coffee_ingredients (coffee_id, ingredient_id, quantity, unit, created_at, updated_at) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);`
	selectCoffees     = `SELECT id, name, teaser, collection, origin, color, description, price, image, created_at, updated_at FROM coffees`
	OrderByIdAsc      = `ORDER BY id ASC`
	selectIngredients = `SELECT ingredient_id, quantity, unit FROM coffee_ingredients WHERE coffee_id=$1`
	updateCoffee      = `UPDATE coffees SET name=$1, teaser=$2, collection=$3, origin=$4, color=$5, description=$6, price=$7, image=$8, updated_at=CURRENT_TIMESTAMP WHERE id=$9;`
)

// Delete removes the given coffee from the database and its ingredient associations from the database.
// It returns a non-nil error if the operation fails.
func (db *CoffeeDB) Delete(ctx context.Context, coffee Coffee) (Coffee, error) {
	c, err := db.Get(ctx, coffee)
	if err != nil {
		return coffee, err
	}
	// Delete all ingredient references
	err = db.exec(ctx, deleteIngredients, 0, coffee.ID)
	if err != nil {
		return c, fmt.Errorf("failed to delete coffee ingredients: %w", err)
	}
	// Delete the coffee
	return c, db.exec(ctx, deleteCoffee, 1, coffee.ID)
}

// Get returns the Coffee that matches all the fields in the given Coffee filter.
// The SELECT operation uses an AND for all non-zero fields in the given filter.
// It returns ErrNotFound if the Coffee with the given id does not exist.
// It returns a non-nil error if the operation fails.
func (db *CoffeeDB) Get(ctx context.Context, filter Coffee) (Coffee, error) {
	where, args := db.buildFilter(filter)
	sql := selectCoffees + where
	coffees, err := db.coffees(ctx, sql, args...)
	if err != nil {
		return Coffee{}, fmt.Errorf("failed to query db: %w", err)
	}

	if len(coffees) > 0 {
		return coffees[0], nil
	}

	return Coffee{}, ErrNotFound
}

// List returns all the coffees from the database.
// It returns a non-nil error if the operation fails.
func (db *CoffeeDB) List(ctx context.Context) ([]Coffee, error) {
	return db.coffees(ctx, selectCoffees+" "+OrderByIdAsc)
}

// Upsert inserts or updates the given coffee record and its ingredient associations.
// It returns a non-nil error if the operation fails.
func (db *CoffeeDB) Upsert(ctx context.Context, coffee Coffee) (Coffee, error) {
	_, err := db.Get(ctx, Coffee{ID: coffee.ID})
	if err != nil && err != ErrNotFound {
		return coffee, fmt.Errorf("failed to get coffee for upsert: %w", err)
	}

	var sql string
	var args []interface{}
	switch err {
	case ErrNotFound:
		// Insert new coffee.
		coffee.ID = -1 // don't include ID in search filter.
		sql = insertCoffee
		args = []interface{}{coffee.Name, coffee.Teaser, coffee.Collection, coffee.Origin, coffee.Color, coffee.Description, coffee.Price, coffee.Image}
	default:
		// Update existing coffee.
		sql = updateCoffee
		args = []interface{}{coffee.Name, coffee.Teaser, coffee.Collection, coffee.Origin, coffee.Color, coffee.Description, coffee.Price, coffee.Image, coffee.ID}
	}

	// Record the coffee.
	err = db.exec(ctx, sql, 1, args...)
	if err != nil {
		return coffee, fmt.Errorf("failed to upsert coffee: %w", err)
	}

	// Add the ingredient entries.
	if err = db.upsertIngredients(ctx, coffee); err != nil {
		return coffee, fmt.Errorf("failed to upsert ingredients: %w", err)
	}

	// Return the fully populated coffee.
	return db.Get(ctx, coffee)
}

func (db *CoffeeDB) upsertIngredients(ctx context.Context, coffee Coffee) error {
	// Get the coffee entry.
	dbCoffee, err := db.Get(ctx, coffee)
	if err != nil {
		return fmt.Errorf("failed to get coffee for ingredient upsert: %w", err)
	}

	// Set the list of ingredients to the input ingredients.
	dbCoffee.Ingredients = coffee.Ingredients

	// This is a brute force approach for the sake of time:
	// delete all the ingredients for this coffee and re-add the new ones.
	err = db.exec(ctx, deleteIngredients, 0, dbCoffee.ID)
	if err != nil {
		return fmt.Errorf("failed to delete coffee ingredients: %w", err)
	}

	// Insert new ingredients entry for each ingredient
	for _, ingredient := range coffee.Ingredients {
		sql := insertIngredient
		args := []interface{}{dbCoffee.ID, ingredient.ID, ingredient.Quantity, ingredient.Unit}
		err = db.exec(ctx, sql, 1, args...)
		if err != nil {
			return fmt.Errorf("failed to insert ingredient for coffee '%s': %w", sql, err)
		}
	}
	return nil
}

func (db *CoffeeDB) coffees(ctx context.Context, sql string, args ...interface{}) ([]Coffee, error) {
	var coffees []Coffee

	// Create the transaction
	tx, err := db.conn.Begin(ctx)
	if err != nil {
		return coffees, fmt.Errorf("failed to begin db transaction: %w", err)
	}

	// Query for the coffees
	rows, err := tx.Query(ctx, sql, args...)
	if err != nil {
		tx.Rollback(ctx)
		return coffees, fmt.Errorf("failed to execute query '%s': %w", sql, err)
	}

	for rows.Next() {
		coffee, err := db.toCoffee(rows)
		if err != nil {
			return coffees, fmt.Errorf("failed to convert db row into coffee: %w", err)
		}
		coffees = append(coffees, coffee)
	}

	// Get the ingredients for each coffee
	for i := range coffees {
		iRows, err := tx.Query(ctx, selectIngredients, coffees[i].ID)
		if err != nil {
			tx.Rollback(ctx)
			return coffees, fmt.Errorf("failed to query ingredients '%s': %w", selectIngredients, err)
		}
		for iRows.Next() {
			var ingredient Ingredient
			err = iRows.Scan(&ingredient.ID, &ingredient.Quantity, &ingredient.Unit)
			if err != nil {
				tx.Rollback(ctx)
				return coffees, fmt.Errorf("failed to convert db row into ingredient: %w", err)
			}
			coffees[i].Ingredients = append(coffees[i].Ingredients, ingredient)
		}
	}

	// Commit the result
	err = tx.Commit(ctx)
	if err != nil {
		tx.Rollback(ctx)
		return coffees, fmt.Errorf("failed to commit tx '%s': %w", sql, err)
	}

	return coffees, nil
}

func (db *CoffeeDB) exec(ctx context.Context, sql string, count int, args ...interface{}) error {
	// Create the transaction
	tx, err := db.conn.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin db transaction: %w", err)
	}

	// Execute the statement
	tag, err := tx.Exec(ctx, sql, args...)
	if err != nil {
		tx.Rollback(ctx)
		return fmt.Errorf("failed to execute query '%s': %w", sql, err)
	}
	rowCount := int(tag.RowsAffected())
	if count != 0 && rowCount != count {
		return fmt.Errorf("unexpected row count: want %d, have %d", count, rowCount)
	}

	// Commit the result
	err = tx.Commit(ctx)
	if err != nil {
		tx.Rollback(ctx)
		return fmt.Errorf("failed to commit tx '%s': %w", sql, err)
	}

	return nil
}

func (db *CoffeeDB) toCoffee(rows pgx.Rows) (Coffee, error) {
	var coffee Coffee
	err := rows.Scan(
		&coffee.ID,
		&coffee.Name,
		&coffee.Teaser,
		&coffee.Collection,
		&coffee.Origin,
		&coffee.Color,
		&coffee.Description,
		&coffee.Price,
		&coffee.Image,
		&coffee.Created,
		&coffee.Updated,
	)
	return coffee, err
}

func (db *CoffeeDB) buildFilter(filter Coffee) (string, []interface{}) {
	var filterWhere string
	var filterFields []string
	var filterArgs []interface{}

	argIdx := 1
	if filter.ID >= 0 {
		filterFields = append(filterFields, fmt.Sprintf("id=$%d", argIdx))
		filterArgs = append(filterArgs, filter.ID)
		argIdx++
	}
	if filter.Name != "" {
		filterFields = append(filterFields, fmt.Sprintf("name=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Name)
		argIdx++
	}
	if filter.Teaser != "" {
		filterFields = append(filterFields, fmt.Sprintf("teaser=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Teaser)
		argIdx++
	}
	if filter.Collection != "" {
		filterFields = append(filterFields, fmt.Sprintf("collection=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Collection)
		argIdx++
	}
	if filter.Origin != "" {
		filterFields = append(filterFields, fmt.Sprintf("origin=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Origin)
		argIdx++
	}
	if filter.Color != "" {
		filterFields = append(filterFields, fmt.Sprintf("color=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Color)
		argIdx++
	}
	if filter.Description != "" {
		filterFields = append(filterFields, fmt.Sprintf("description=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Description)
		argIdx++
	}
	if filter.Price != 0 {
		filterFields = append(filterFields, fmt.Sprintf("price=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Price)
		argIdx++
	}
	if filter.Image != "" {
		filterFields = append(filterFields, fmt.Sprintf("image=$%d", argIdx))
		filterArgs = append(filterArgs, filter.Image)
		argIdx++
	}

	if len(filterFields) > 0 {
		filterWhere = " WHERE "
		filterWhere += strings.Join(filterFields, " AND ")
	}

	return filterWhere, filterArgs
}
