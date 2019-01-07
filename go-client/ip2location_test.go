package go_client

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIp2location_ErrInvalidIpAddress(t *testing.T) {
	_, err := Ip2location("", "a")
	assert.Equal(t, ErrInvalidIpAddress, err)
}

// temp test, not a stable test
func TestIp2location(t *testing.T) {
	l, err := Ip2location("http://localhost:8001", "24.19.48.11")
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
