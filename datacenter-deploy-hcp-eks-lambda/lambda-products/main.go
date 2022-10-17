package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/hashicorp/go-hclog"
)

// Set the following env vars on the Lambda function to connect to PGSQL:
// PGHOST = localhost
// PGPORT = 5432
// PGDATABASE = products
// PGUSER = postgres
// PGPASSWORD = password

func main() {
	lambda.Start(Main)
}

func Main(ctx context.Context, i interface{}) (interface{}, error) {
	// Create the logger
	log := hclog.Default()
	log.SetLevel(hclog.LevelFromString(os.Getenv("LOG_LEVEL")))

	// Create the API
	a := NewCoffeeAPI(NewJSONValidator(""))

	// Create the data model
	d, err := NewCoffeeDB(ctx)
	if err != nil {
		log.Error("failed to create database", "error", err)
		return nil, err
	}

	// Create and run the request handler
	handler := &Handler{
		log: log,
		api: a,
		db:  d,
	}
	return handler.Handle(ctx, i)
}

type Handler struct {
	api API
	db  DB
	log hclog.Logger
}

func (h *Handler) Handle(ctx context.Context, i interface{}) (interface{}, error) {
	// Decode and validate the request
	h.log.Debug("handling request", "input", fmt.Sprintf("%#v", i))
	request, err := h.api.DecodeRequest(i)
	if err != nil {
		h.log.Error("bad request", "error", err)
		return nil, fmt.Errorf("bad request: %w", err)
	}

	// Handle the request based on the method
	switch strings.ToUpper(request.Method) {
	case http.MethodGet:
		return h.listCoffees(ctx)
	case http.MethodPut:
		return h.upsertCoffee(ctx, request.Coffee)
	case http.MethodDelete:
		return h.deleteCoffee(ctx, request.Coffee)
	default:
		return nil, fmt.Errorf("bad request: unsupported method %s", request.Method)
	}
}

func (h *Handler) deleteCoffee(ctx context.Context, c Coffee) (Coffee, error) {
	h.log.Debug("deleting coffee", "coffee", c)
	return h.db.Delete(ctx, c)
}

func (h *Handler) upsertCoffee(ctx context.Context, c Coffee) (Coffee, error) {
	h.log.Debug("upserting coffee", "coffee", c)
	return h.db.Upsert(ctx, c)
}

// listCoffees is a test func. It prints the coffees in the product-api-db
func (h *Handler) listCoffees(ctx context.Context) ([]Coffee, error) {
	h.log.Debug("listing coffees")
	coffees, err := h.db.List(ctx)
	if err != nil {
		h.log.Error("failed to list coffees", "error", err)
		return coffees, err
	}
	h.log.Debug("retrieved list of coffees", "coffees", coffees)
	return coffees, err
}
