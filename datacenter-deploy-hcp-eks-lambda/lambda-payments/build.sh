# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

GOOS=linux GOARCH=amd64 go build .
zip lambda-payments.zip lambda-payments
