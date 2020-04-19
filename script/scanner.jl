# Scan all data and build reports
# Available scanners:
#   * Find periods of rainfall
#
using CSV
using Dates


const stations = CSV.read("data/gdanskiewody/stations.csv"; truestrings=["True"], falsestrings=["False"])
