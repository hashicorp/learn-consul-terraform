package main

import (
	"fmt"

	"github.com/mitchellh/mapstructure"
)

type Validator interface {
	Validate(i interface{}) error
}

type CoffeeAPI struct {
	v Validator
}

func NewCoffeeAPI(v Validator) *CoffeeAPI {
	return &CoffeeAPI{v: v}
}

func (c *CoffeeAPI) DecodeRequest(i interface{}) (Request, error) {
	var request Request
	r, ok := i.(map[string]interface{})
	if !ok {
		return request, fmt.Errorf("expected an object")
	}

	// If payload_passthrough is true, then the request body is the root object.
	body := r

	// If payload_passthrough = false then there must be a "body" field.
	if b, ok := r["body"]; ok {
		if bb, ok := b.(map[string]interface{}); ok {
			body = bb
		} else {
			// Not an object so bad request.
			return request, fmt.Errorf("expected an object")
		}
	}

	err := c.v.Validate(body)
	if err != nil {
		err = fmt.Errorf("request validation failed: %w", err)
		return request, err
	}

	err = mapstructure.Decode(body, &request)
	if err != nil {
		err = fmt.Errorf("failed to decode request: %w", err)
	}

	return request, err
}
