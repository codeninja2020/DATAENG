#!/bin/bash
# Script to rename HSBC folders to HXBC

# Rename HSBC folder to HXBC
git mv HSBC HXBC

# Rename HSBC_Datafeed_tenpc folder to HXBC_Datafeed_tenpc
git mv HSBC_Datafeed_tenpc HXBC_Datafeed_tenpc

# Commit the changes
git commit -m "Rename HSBC folders to HXBC: HSBC -> HXBC and HSBC_Datafeed_tenpc -> HXBC_Datafeed_tenpc"

# Push to remote
git push origin main
