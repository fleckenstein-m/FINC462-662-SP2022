#' Activate package environment
using Pkg
Pkg.activate(".")
Pkg.status()


##
#' Add packages
"FredData" ∉ keys(Pkg.project().dependencies) && Pkg.add("FredData")
"Chain" ∉ keys(Pkg.project().dependencies) && Pkg.add("Chain")
"CSV" ∉ keys(Pkg.project().dependencies) && Pkg.add("CSV")
"DataFrames" ∉ keys(Pkg.project().dependencies) && Pkg.add("DataFrames")
"Dates" ∉ keys(Pkg.project().dependencies) && Pkg.add("Dates")
"Missings" ∉ keys(Pkg.project().dependencies) && Pkg.add("Missings")
"Statistics" ∉ keys(Pkg.project().dependencies) && Pkg.add("Statistics")
##


#' Load packages
using FredData, Chain, CSV, DataFrames,  Dates, Missings, Statistics

#initialize FRED API link
f = Fred("18b088f609f773292f68282a279ea274")
#get Treasury constant maturity series

startDate = "1995-01-01"
endDate = "2021-11-04"
obsFreq = "d"
cmt_1m = get_data(f, "DGS1MO"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_3m = get_data(f, "DGS3MO"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_6m = get_data(f, "DGS6MO"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_1y = get_data(f, "DGS1"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_2y = get_data(f, "DGS2"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_3y = get_data(f, "DGS3"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_5y = get_data(f, "DGS5"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_7y = get_data(f, "DGS7"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_10y = get_data(f, "DGS10"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_20y = get_data(f, "DGS20"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)
cmt_30y = get_data(f, "DGS30"; frequency=obsFreq, observation_start = startDate, observation_end  = endDate)

#extract data series
cmt_1m_data = cmt_1m.data[:,[:date, :value]]
select!(cmt_1m_data, :date => :Date, :value => :CMT_1M)
cmt_3m_data = cmt_3m.data[:,[:date, :value]]
select!(cmt_3m_data, :date => :Date, :value => :CMT_3M)
cmt_6m_data = cmt_6m.data[:,[:date, :value]]
select!(cmt_6m_data, :date => :Date, :value => :CMT_6M)
cmt_1y_data = cmt_1y.data[:,[:date, :value]]
select!(cmt_1y_data, :date => :Date, :value => :CMT_1Y)
cmt_2y_data = cmt_2y.data[:,[:date, :value]]
select!(cmt_2y_data, :date => :Date, :value => :CMT_2Y)
cmt_3y_data = cmt_3y.data[:,[:date, :value]]
select!(cmt_3y_data, :date => :Date, :value => :CMT_3Y)
cmt_5y_data = cmt_5y.data[:,[:date, :value]]
select!(cmt_5y_data, :date => :Date, :value => :CMT_5Y)
cmt_7y_data = cmt_7y.data[:,[:date, :value]]
select!(cmt_7y_data, :date => :Date, :value => :CMT_7Y)
cmt_10y_data = cmt_10y.data[:,[:date, :value]]
select!(cmt_10y_data, :date => :Date, :value => :CMT_10Y)
cmt_20y_data = cmt_20y.data[:,[:date, :value]]
select!(cmt_20y_data, :date => :Date, :value => :CMT_20Y)
cmt_30y_data = cmt_30y.data[:,[:date, :value]]
select!(cmt_30y_data, :date => :Date, :value => :CMT_30Y)


#join cmt time series
CMT = outerjoin(cmt_1m_data, cmt_3m_data, on = :Date)
CMT = outerjoin(CMT, cmt_6m_data, on = :Date)
CMT = outerjoin(CMT, cmt_1y_data, on = :Date)
CMT = outerjoin(CMT, cmt_2y_data, on = :Date)
CMT = outerjoin(CMT, cmt_3y_data, on = :Date)
CMT = outerjoin(CMT, cmt_5y_data, on = :Date)
CMT = outerjoin(CMT, cmt_7y_data, on = :Date)
CMT = outerjoin(CMT, cmt_10y_data, on = :Date)
CMT = outerjoin(CMT, cmt_20y_data, on = :Date)
CMT = outerjoin(CMT, cmt_30y_data, on = :Date)
for col in eachcol(CMT)
    replace!(col, NaN => missing)
end
dropmissing!(CMT)
disallowmissing!(CMT)

#write to csv
CSV.write("CMT.csv", CMT)