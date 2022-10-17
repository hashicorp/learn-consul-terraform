package main

import (
	"context"
	"time"
)

type Request struct {
	Method string `json:"method"`
	Coffee Coffee `json:"coffee"`
}

type Coffee struct {
	ID          int          `json:"id"`
	Name        string       `json:"name"`
	Teaser      string       `json:"teaser"`
	Collection  string       `json:"collection"`
	Origin      string       `json:"origin"`
	Color       string       `json:"color"`
	Description string       `json:"description"`
	Price       int          `json:"price"`
	Image       string       `json:"image"`
	Ingredients []Ingredient `json:"ingredients"`
	Created     time.Time    `json:"-"`
	Updated     time.Time    `json:"-"`
}

type Ingredient struct {
	ID       int    `json:"id"`
	Quantity int    `json:"quantity"`
	Unit     string `json:"unit"`
}

type API interface {
	DecodeRequest(interface{}) (Request, error)
}

type DB interface {
	List(context.Context) ([]Coffee, error)
	Upsert(context.Context, Coffee) (Coffee, error)
	Delete(context.Context, Coffee) (Coffee, error)
}
