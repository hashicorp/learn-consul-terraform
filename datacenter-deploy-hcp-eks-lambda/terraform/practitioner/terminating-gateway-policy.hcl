service "payments" {
      policy = "write"
      intentions = "read"
}

service_prefix "payments-lambda" {
      policy = "write"
      intentions = "read"
}

// service "payments-lambda-w19vbd" {
//       policy = "write"
//       intentions = "read"
// }
