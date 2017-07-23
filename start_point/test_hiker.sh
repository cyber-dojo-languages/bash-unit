#!/bin/bash

. ./hiker.sh

function test_life_the_universe_and_everything()
{
  local expected=42
  local actual=$(answer)
  assert_equals ${expected} ${actual}
}
