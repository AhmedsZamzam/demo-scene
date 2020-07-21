package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
)

func alertSpaces(c int) (err error) {

	// Prepare the request
	url := "http://localhost:8088/query"
	method := "POST"
	k := "SELECT NAME, TS, CAPACITY, EMPTY_PLACES FROM CARPARK_EVENTS  WHERE  EMPTY_PLACES > " + strconv.Itoa(c) + "  EMIT CHANGES;"
	payload := strings.NewReader("{\"ksql\":\"" + k + "\"}")

	// Create the client
	client := &http.Client{}
	req, err := http.NewRequest(method, url, payload)
	if err != nil {
		return err
	}
	req.Header.Add("Content-Type", "application/vnd.ksql.v1+json; charset=utf-8")

	// Make the request
	res, err := client.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	// Parse the stream of results
	var CARPARK string
	var DATA_TS float64
	var CURRENT_EMPTY_PLACES float64
	var CAPACITY float64
	var r ksqlDBMessageRow

	reader := bufio.NewReader(res.Body)
	doThis := true
	for doThis {
		// Read the next chunk
		lb, err := reader.ReadBytes('\n')
		if err != nil {
			doThis = false
		}

		if len(lb) > 2 {
			//fmt.Printf("\nGot some data:\n\t%v", string(lb))

			// Do a dirty hack to remove the trailing comma and \r so that the `row` can be
			// parsed as JSON
			// e.g.
			// {"row":{"columns":["Burnett St",1595373720000,122,117]}},
			//   becomes
			// {"row":{"columns":["Burnett St",1595373720000,122,117]}}
			lb = lb[:len(lb)-2]

			// Convert the JSON to Go object
			if strings.Contains(string(lb), "row") {
				// Looks like a Row, let's process it!
				err = json.Unmarshal(lb, &r)
				if err != nil {
					fmt.Printf("Error decoding JSON %v (%v)\n", string(lb), err)
				} else {
					if r.Row.Columns != nil {
						CARPARK = r.Row.Columns[0].(string)
						DATA_TS = r.Row.Columns[1].(float64)
						CURRENT_EMPTY_PLACES = r.Row.Columns[2].(float64)
						CAPACITY = r.Row.Columns[3].(float64)
						// Handle the timestamp
						t := int64(DATA_TS)
						ts := time.Unix(t/1000, 0)
						fmt.Printf("Carpark %v at %v has %v spaces available (capacity %v)\n", CARPARK, ts, CURRENT_EMPTY_PLACES, CAPACITY)
					}
				}
			} else {
				//fmt.Printf("-> Ignoring JSON as it doesn't look like a Row\n")
				continue
			}
		}
	}

	return nil
}
