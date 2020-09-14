package go_client

import (
	"errors"
	"net"
	"net/http"
	"strconv"
)

var (
	ErrInvalidIpAddress = errors.New("invalid ip address")
)

type Location struct {
	CountryCode string
	CountryName string
	Region      string
	City        string
	Latitude    float64
	Longitude   float64
	Zipcode     string
	Timezone    string
}

func NewClient(serviceUrl string) *Client {
	return &Client{
		serviceUrl: serviceUrl,
	}
}

type Client struct {
	serviceUrl string
}

func (c *Client) Ip2location(ip string) (*Location, error) {
	if err := validateIpAddress(ip); err != nil {
		return nil, err
	}

	req, err := http.NewRequest(http.MethodGet, c.serviceUrl, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("IP2Location-IP", ip)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	lat, err := parseFloat64(resp.Header.Get("IP2Location-Latitude"))
	if err != nil {
		return nil, err
	}

	long, err := parseFloat64(resp.Header.Get("IP2Location-Longitude"))
	if err != nil {
		return nil, err
	}

	return &Location{
		CountryCode: resp.Header.Get("IP2Location-Country-Code"),
		CountryName: resp.Header.Get("IP2Location-Country-Name"),
		Region:      resp.Header.Get("IP2Location-Region"),
		City:        resp.Header.Get("IP2Location-City"),
		Latitude:    lat,
		Longitude:   long,
		Zipcode:     resp.Header.Get("IP2Location-Zipcode"),
		Timezone:    resp.Header.Get("IP2Location-Timezone"),
	}, nil
}

func parseFloat64(s string) (float64, error) {
	if s == "" {
		s = "0"
	}

	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, err
	}

	return f, nil
}

func validateIpAddress(ipAddress string) error {
	ip := net.ParseIP(ipAddress)
	//if ip == nil || ip.IsUnspecified() {
	if ip == nil {
		return ErrInvalidIpAddress
	}

	return nil
}
