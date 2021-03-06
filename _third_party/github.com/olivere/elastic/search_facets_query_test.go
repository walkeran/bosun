// Copyright 2012-2015 Oliver Eilhard. All rights reserved.
// Use of this source code is governed by a MIT-license.
// See http://olivere.mit-license.org/license.txt for details.

package elastic

import (
	"encoding/json"
	"testing"
)

func TestQueryFacet(t *testing.T) {
	f := NewQueryFacet().Query(NewTermQuery("tag", "wow"))
	data, err := json.Marshal(f.Source())
	if err != nil {
		t.Fatalf("marshaling to JSON failed: %v", err)
	}
	got := string(data)
	expected := `{"query":{"term":{"tag":"wow"}}}`
	if got != expected {
		t.Errorf("expected\n%s\n,got:\n%s", expected, got)
	}
}

func TestQueryFacetWithGlobals(t *testing.T) {
	f := NewQueryFacet().Query(NewTermQuery("tag", "wow")).
		Global(true).
		FacetFilter(NewTermFilter("user", "kimchy"))
	data, err := json.Marshal(f.Source())
	if err != nil {
		t.Fatalf("marshaling to JSON failed: %v", err)
	}
	got := string(data)
	expected := `{"facet_filter":{"term":{"user":"kimchy"}},"global":true,"query":{"term":{"tag":"wow"}}}`
	if got != expected {
		t.Errorf("expected\n%s\n,got:\n%s", expected, got)
	}
}
