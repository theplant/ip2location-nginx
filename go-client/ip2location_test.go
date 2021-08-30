package go_client

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

var (
	client *Client
)

func TestMain(m *testing.M) {
	client = NewClient("http://localhost:9080")

	os.Exit(m.Run())
}

func TestIp2location_ErrInvalidIpAddress(t *testing.T) {
	_, err := client.Ip2location("a")
	assert.Equal(t, ErrInvalidIpAddress, err)
}

// temp test, not a stable test
func TestIp2location(t *testing.T) {
	l, err := client.Ip2location("24.19.48.11")
	assert.NoError(t, err)
	assert.Equal(t, &Location{
		CountryCode: "US",
		CountryName: "United States",
		Region:      "Washington",
		City:        "Seattle",
		Latitude:    47.606209,
		Longitude:   -122.332069,
		Zipcode:     "98101",
		Timezone:    "-08:00",
	}, l)
}
