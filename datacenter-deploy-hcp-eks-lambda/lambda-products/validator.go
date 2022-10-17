package main

type JSONValidator struct {
	schema string
}

func NewJSONValidator(schema string) *JSONValidator {
	return &JSONValidator{schema: schema}
}

func (v *JSONValidator) Validate(i interface{}) error {
	// TODO: validate request against JSON schema
	// :thinkies: Marshal to JSON -> validate -> Unmarshal seems heavy
	// Is there a way to validate map[string]interface against JSONschema?
	return nil
}
