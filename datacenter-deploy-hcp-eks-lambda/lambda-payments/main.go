package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/google/uuid"
)

type Request struct {
	Method string `json:"method"`
	Body   string `json:"body"`
}

type RequestBody struct {
	Name   string `json:"name"`
	Type   string `json:"type"`
	Number string `json:"number"`
	Expiry string `json:"expiry"`
	CVC    string `json:"cvc"`
}

type Response struct {
	StatusCode int    `json:"statusCode"`
	Body       string `json:"body"`
}

type ResponseBody struct {
	Message        string `json:"message"`
	ID             string `json:"id"`
	CardPlaintext  string `json:"card_plaintext"`
	CardCiphertext string `json:"card_ciphertext"`
}

func HandleRequest(ctx context.Context, request Request) (Response, error) {
	if request.Method != "POST" {
		return Response{StatusCode: 400, Body: "Only POST is supported"}, nil
	}

	if len(request.Body) == 0 {
		return Response{StatusCode: 400, Body: "Error decoding body"}, nil
	}
	var requestBody RequestBody
	err := json.Unmarshal([]byte(request.Body), &requestBody)

	if err != nil {
		return Response{StatusCode: 400, Body: "Error decoding body"}, nil
	}
	fmt.Println("BODY: %+v\n", requestBody)

	responseBody := &ResponseBody{
		Message:        "Payment processed successfully, card details returned for demo purposes, not for production",
		ID:             uuid.New().String(),
		CardPlaintext:  requestBody.Number,
		CardCiphertext: "Encryption Enabled",
	}

	rawResponse, err := json.Marshal(responseBody)
	if err != nil {
		return Response{StatusCode: 400, Body: "Error encoding response"}, nil
	}

	return Response{StatusCode: 200, Body: string(rawResponse)}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
