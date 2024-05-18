package main

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

func TestMongoDBAtlasConnection(t *testing.T) {
	// Define the MongoDB Atlas connection string
	uri := fmt.Sprintf("mongodb+srv://<username>:<password>@%s/?retryWrites=true&w=majority", "<cluster-url>")

	// Retryable function to connect to MongoDB Atlas
	retry.DoWithRetry(t, "Connecting to MongoDB Atlas", 30, 5*time.Second, func() (string, error) {
		// Create a new MongoDB client
		client, err := mongo.NewClient(options.Client().ApplyURI(uri))
		if err != nil {
			return "", err
		}

		// Set a timeout context for the connection
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Connect to the MongoDB Atlas cluster
		err = client.Connect(ctx)
		if err != nil {
			return "", err
		}
		defer client.Disconnect(ctx)

		// Ping the primary to verify connection
		err = client.Ping(ctx, readpref.Primary())
		if err != nil {
			return "", err
		}

		// If successful, return a success message
		return "Connected to MongoDB Atlas", nil
	})
}
