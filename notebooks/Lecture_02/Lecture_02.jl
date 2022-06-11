### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ a2f22b9d-13f8-4e39-b7dd-14b905d987ab
#add button to trigger presentation mode
html"<button onclick='present()'>present</button>"

# ╔═╡ 731c88b4-7daf-480d-b163-7003a5fbd41f
begin 
	html"""
	<p align=left style="font-size:36px; font-family:family:Georgia"> <b> FINC 462/662 -- Fixed Income Securities</b> <p>
	"""
end

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> The U.S. Treasury Market</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.05cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0cm"> </p>
	"""
end

# ╔═╡ 69dca09e-b572-436f-90c6-187af17cf027
TableOfContents(aside=true, depth=1)

# ╔═╡ 6498b10d-bece-42bf-a32b-631224857753
md"""
# Overview
"""

# ╔═╡ 95db374b-b10d-4877-a38d-1d0ac45877c4
begin
	html"""
	<fieldset>      
        <legend>Our goals for today</legend>      
		<br>
        <input type="checkbox" value="">Know the different types of securities issued by the U.S. Department of the Treasury<br>      
		<br>
        <input type="checkbox" value="">Be familiar with the Treasury auction process.
<br>
<br>
	  	</fieldset>      
	"""
end

# ╔═╡ 10a73b76-b6ad-4081-b8b1-21363608618e
md"""
# The U.S. Treasury Market
- The Department of the Treasury is the largest single issuer of debt in the world.
- The large volume of total debt and the large size of any single issue have contributed to making the Treasury market the most active and hence the most liquid market in the world


[SIFMA Fixed Income Statistics](https://www.sifma.org/resources/research/fixed-income-chart)
"""

# ╔═╡ 42f7e15d-9abc-40ca-bd70-7131957907a5
md"""
- Why the Treasury Market matters ...
  - [WSJ, February 1, 2022: U.S. National Debt Exceeds $30 Trillion for First Time](https://www.wsj.com/articles/u-s-national-debt-exceeds-30-trillion-for-first-time-11643766231?mod=hp_lead_pos3)
"""

# ╔═╡ b33e1473-e374-441b-a6a4-6c2a7b079c98
md"""
## U.S. Treasury Debt Amount Outstanding
Year-end data in trillions of dollars. \
_Source: SIFMA_
"""

# ╔═╡ 7bb29c12-c0a0-4eb0-a4d6-bd9c52443751
#Treasury Market Amounts Outstanding
begin
	FI_Out = DataFrame()
	plot_Outstanding = plot()
	let
		file="./US-Fixed-Income-Securities-Statistics-SIFMA.xlsx"
		sheet="Outstanding"
		cols="A:I"
		startrow = 8
		xlsxFile = XLSX.readtable(file, sheet, cols; first_row=startrow, header=true, 			infer_eltypes=true)
		FI_Out = DataFrame(xlsxFile...)
				
		catSelect="Treasury"
		println(catSelect)
		plotData = select(FI_Out, "Year","$(catSelect)")
		rename!(plotData,"Year" => :x, "$(catSelect)" => :y)
		dropmissing!(plotData)
		transform!(plotData, :y => ByRow(x->x/1000), renamecols=false)
		minX = 1975
		maxX = 2025
		minY = 0.0
		maxY = 25.0
		plot!(plot_Outstanding, plotData.x,plotData.y, 
			xlim=(minX,maxX), ylim=(minY, maxY),
			ylabel="Trillions of Dollars",label="$(catSelect)",
			legend = :topleft, title="Amount Outstanding")	
		plot(plot_Outstanding)
	end
end

# ╔═╡ f89f6fc4-cb6f-4d7b-84c9-f8a18e764427
md"""
##
"""

# ╔═╡ 313959e0-eea6-449a-a6b8-29c9394e50b6
LocalResource("./TreasuryOutstandingSIFMA.svg",:width => 900)

# ╔═╡ e20b95fa-e038-4d3b-82ca-8a38262c64c4
md"""
[Link to SIFMA](https://www.sifma.org/resources/research/fixed-income-chart/)
"""

# ╔═╡ 2bf62523-a0f1-400e-9178-79062e0a171e
md"""
## U.S. Treasury Debt Amount Issued
Annual data at year-end in trillions of dollars.\
_Source: SIFMA_
"""

# ╔═╡ 206df1a6-bf12-4957-93f7-472ee89594c4
#US Treasury Securities Amounts Issued
begin
	FI_Iss = DataFrame()
	plot_Issuance = plot()
	let
		file="./US-Fixed-Income-Securities-Statistics-SIFMA.xlsx"
		sheet="Issuance"
		cols="A:H"
		startrow = 8
		xlsxFile = XLSX.readtable(file, sheet, cols; first_row=startrow, 
			header=true, infer_eltypes=true)
		FI_Iss = DataFrame(xlsxFile...)
		
		catSelect="Treasury"
		plotData = select(FI_Iss, "Year","$(catSelect)")
		rename!(plotData,"Year" => :x, "$(catSelect)" => :y)
		dropmissing!(plotData)
		transform!(plotData, :y => ByRow(x->x/1000), renamecols=false)
		minX = 1994
		maxX = 2021
		minY = 0.0
		maxY = 4.0
		plot!(plot_Issuance, plotData.x,plotData.y, 
			xlim=(minX,maxX), ylim=(minY, maxY),
			ylabel="Trillions of Dollars",label="$(catSelect)",
			legend = :topleft, title="Amount Issued")	
		plot(plot_Issuance)
	end
end


# ╔═╡ c8f703dc-5a1c-4c39-b9a4-c3dd0a2806d8
md"""
##
"""

# ╔═╡ 13a58974-2ae8-4596-933f-5d2b5b8f5a23
LocalResource("./TreasuryIssuanceSIFMA.svg",:width => 900)

# ╔═╡ c7b5fcd2-a727-4bde-aae3-cd39dfb9a43b
md"""
##
"""

# ╔═╡ e89beeee-1ad9-4440-ba95-9bd0eb6bfe72
md"""
_Note_: Issuance is long-term instruments only.\
[Link to SIFMA](https://www.sifma.org/resources/research/fixed-income-chart/)
"""

# ╔═╡ 7f91ba74-ccca-4f08-8252-9de7f956b285
LocalResource("./TreasuryIssuanceSIFMA.png",:width => 900)

# ╔═╡ 84009ee2-cfc3-437c-8782-d370b8b8c4f6
md"""
##
"""

# ╔═╡ a2df8dc1-f6da-4816-85b9-c7caadc03584
#Treasury Market Total Amount Outstanding vs Equity
begin
	
	plot_MktCap = plot()
	let
		file="./MarketCaps.xlsx"
		sheet="Sheet1"
		cols="A:B"
		startrow = 8
		xlsxFile = XLSX.readtable(file, sheet, cols; first_row=startrow, header=false,
			column_labels=["Date","Equity"], infer_eltypes=true)
		EquMktCap = DataFrame(xlsxFile...)
		dropmissing!(EquMktCap)
		transform!(EquMktCap,:Equity=>(x->x./1000)=>:Equity, 
			:Date => (x->year.(x)) => :Year,
			:Date => (x->month.(x)) => :Month)
		filter!(:Month => ==(12),EquMktCap)
		MktCaps = leftjoin(EquMktCap,FI_Out[:,[:Year,:Treasury]], on=:Year)
		select!(MktCaps,:Year,:Treasury,:Equity)
		transform!(MktCaps,names(MktCaps,Not(:Year)) .=> (x->x./1000.0),
			renamecols=false)
		minX = minimum(MktCaps.Year)-1
		maxX = maximum(MktCaps.Year)+1
		minY = 0.0
		maxY = 50.0
		plot!(plot_MktCap, MktCaps.Year,MktCaps.Treasury, 
			  xlim=(minX,maxX), ylim=(minY, maxY),
			  ylabel="Trillions of Dollars", label="Fixed Income",
			  legend = :topleft, title="US Treasury vs. Equity Markets")	
		plot!(plot_MktCap, MktCaps.Year,MktCaps."Equity", 
			  label="Equity")	
     	plot(plot_MktCap)
	end
end

# ╔═╡ 5db80dee-c643-4cc1-bca4-00b1ffd0a948
md"""
## U.S. Treasury Securities Trading Volume
Average Daily Trading Volume. Annual data at year-end in billions of dollars.\
_Source: SIFMA_
"""

# ╔═╡ 0357258e-8133-4ef3-946f-5134a9560b9d
#US Treasury Market Trading Volumes
begin
	FI_Vol = DataFrame()
	plot_Vol = plot()
	let
		file="./US-Fixed-Income-Securities-Statistics-SIFMA.xlsx"
		sheet="Trading Volume"
		cols="A:I"
		startrow = 8
		xlsxFile = XLSX.readtable(file, sheet, cols; first_row=startrow, 
			header=true, infer_eltypes=true)
		FI_Vol = DataFrame(xlsxFile...)
		
		catSelect="Treasury"
		plotData = select(FI_Vol, "Year","$(catSelect)")
		rename!(plotData,"Year" => :x, "$(catSelect)" => :y)
		dropmissing!(plotData)
		minX = 1995
		maxX = 2021
		minY = 0.0
		maxY = 650.0
		plot!(plot_Vol, plotData.x,plotData.y, 
			xlim=(minX,maxX), ylim=(minY, maxY),
			ylabel="Billions of Dollars",label="$(catSelect)",
			legend = :topleft, title="Trading Volume")	
		plot(plot_Vol)
	end
end

# ╔═╡ ae67f236-60ec-4c2e-abd3-9ea537200ca3
md"""
# Types of Treasury Securities
"""

# ╔═╡ fa1dcebd-4a54-433b-897c-de2929fb8233
md"""
>- Where to get information about U.S. Treasury securities?
>- Go to webpage of the [U.S. Treasury](https://www.treasurydirect.gov/).
>- In the middle panel, click on `Treasury securities Overview`.
"""

# ╔═╡ 2452e56b-2a61-4608-9ca0-55c8cdca89c6
LocalResource("TreasuryDirect_01.png",:width => 900)

# ╔═╡ f688e93c-e8b1-4718-b56e-d76bf70eef57
md"""
##
"""

# ╔═╡ 4914c857-5dc8-43b8-8e70-377debbc3d0c
LocalResource("TreasuryDirect_02.png",:width => 900)

# ╔═╡ d25744ad-fbe3-4f08-b17a-d00d51bcb2b8
md"""
# Treasury Bill (T-bill)
- Short-term securities with maturities of 4, 13, 26, and 52 weeks.
- Treasury bills do not pay interest before maturity.
  - This is often referred to as a _discount security_ or _zero-coupon security_.
- Instead, Treasury bills are issued at a price less than their par value and at maturity, Treasury bills pay back their par value.
  - Intuitively, the “interest” to the investor is the difference between par value and the purchase price.
  - Example: a 52-week T-bill with par value of \$100 has a price of \$98.
"""

# ╔═╡ 382a9c58-4baa-4ad2-9f32-7189d4881c50
md"""
## Example of 52-week Treasury Bill
"""

# ╔═╡ deb54591-8769-480d-98ad-32157abac2c0
LocalResource("./BloombergTBill_01.png", :width=>900)

# ╔═╡ 3578793a-e0b6-42de-941b-2db09ef99e49
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `T Bill`.
>  - In the popup window,  select `B Govt - United States Treasury Bill (Multiple Matches)`.
>  - Next, click on one of the different Treasury bills in the list.
>  - Then, click on `DES` on the top-right, or type `DES` on the keyboard and press enter.
"""

# ╔═╡ 82db2847-a1a1-45a3-8d29-c3ac4213591c
md"""
##
"""

# ╔═╡ adbc8a60-c33c-44ba-a284-fa7b676b9618
md"""
- Let's look at price quotes for this Treasury bill.
- If you were to purchase this Treasury bill, would you pay \$0.8450?
- The answer is _no_. Prices for Treasury bills are quoted in a specific way, which we will discuss in the next lecture.
"""

# ╔═╡ 1a6add34-52e1-4663-9228-f0fca63f8cc2
LocalResource("./BloombergTBill_02.png")

# ╔═╡ 8de081f6-2b7f-4d03-b565-b4ac01c2773e
md"""
>- How to get there on the Bloomberg terminal?
>  - From the `Description` page where you are currently at, type `GP` and press enter.
"""

# ╔═╡ d296b99d-588d-48ac-8e0c-a0bcbde72c56
md"""
# Treasury Note (T-Note)
- Medium-term securities with maturities of 2, 3, 5, 7, and 10 years.
- Treasury notes pay interest every six months up to and including the maturity date.
  - Example: A 2-year T-note has its last interest payment in two years, and it pays interest after 6 months, 12 months, and 18 months.
- At maturity, Treasury notes pay back their par value.
"""

# ╔═╡ 1c4db2fa-7187-4966-aa3f-9a7f56036497
md"""
## Example of 10-year Treasury Note
"""

# ╔═╡ 3a3b7641-ed63-4cce-a98c-a4cf1b6e603d
LocalResource("./BloombergTNote_01.png")

# ╔═╡ 2384b88b-e8dc-4e9c-9488-27828da0289d
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `T Note`.
>  - In the popup window,  select `T Govt - United States Treasury Note/Bond (Multiple Matches)`.
>  - Next, click on one of the different Treasury notes in the list.
>  - Then, click on `DES` on the top-right, or type `DES` on the keyboard and press enter.
"""

# ╔═╡ 0918383a-9a0b-4f8c-ba63-aaad1cf6d72c
md"""
- Let's look at price quotes for this Treasury note.
- If you were to purchase this Treasury note, would you pay \$95.02?
- The answer is _no_. Prices for Treasury notes are quoted in a specific way, which we will discuss in the next lecture.
"""

# ╔═╡ c9b876e2-cb29-4a70-9c1f-abb2dedf3fe2
LocalResource("./BloombergTNote_02.png")

# ╔═╡ d912c3cb-c1a6-46fe-af9d-25a75074b31d
md"""
>- How to get there on the Bloomberg terminal?
>  - From the `Description` page where you are currently at, type `GP` and press enter.
"""

# ╔═╡ 40df1177-48cf-4cb2-9860-11d2d9f0a450
md"""
# Treasury Bond (T-Bond)
- Long-term securities with maturities of 20 and 30 years.
  - Currently, the Treasury does not issue 15-year Treasury bonds.
- Treasury bonds notes pay interest every six months up to and including the maturity date. At maturity, Treasury notes pay back their par value.
  - Similar to Treasury notes.

[Treasury Marketable Securities](https://www.treasurydirect.gov/instit/marketables/marketables.htm)
"""

# ╔═╡ 4567e3a2-24fb-494f-8005-801b03ffeabf
#https://www.treasurydirect.gov/indiv/research/history/histtime/histtime_bonds.htm

# ╔═╡ 76774fcb-f806-4db2-b653-fe69720f43a7
md"""
## Coupon bonds
- Treasury notes and bonds are referred to as **coupon** securities.
- Why?
"""

# ╔═╡ a440a28f-04af-4248-8f2b-c8e6a726c07a
LocalResource("TreasuryCouponPicture.svg",:width => 900)

# ╔═╡ fef5577e-025f-4afc-9fd9-aa025146858e
md"""
# Treasury Floating Rate Note (FRN)
- First issued in 2014 by the U.S. Treasury.
- Maturity of 2 years.
- Pay interest every three months up to and including the maturity date.
  - At maturity, FRNs pay back their par value.
- The interest on an FRN varies with interest rate on 13-week Treasury bills.
"""

# ╔═╡ 90883b07-064f-4395-a805-ddaaad7f97fd
md"""
## Example of Treasury Floating Rate Note (FRN)
"""

# ╔═╡ faecc806-5f33-49c6-a463-b349cbfb8acc
LocalResource("./BloombergFRN_01.png")

# ╔═╡ c7a254a6-d877-4de0-a3e5-a64fb93ae079
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `Treasury Floating Rate Note`.
>  - In the popup window,  select `TF Govt - United States Treasury Floating Rate Note (Multiple Matches)`.
>  - Next, click on one of the different Treasury FRNs in the list.
>  - Then, click on `DES` on the top-right, or type `DES` on the keyboard and press enter.
"""

# ╔═╡ 9b53686c-e362-46c5-bdd9-0c388d9cd122
LocalResource("./BloombergFRN_02.png")

# ╔═╡ 9d0017a5-6b7b-4c1b-9323-7a8fdc54db77
md"""
- Let's look at price quotes for this Treasury FRN.
- If you were to purchase this Treasury FRN, would you pay \$100.1674?
- Generally, the answer is _no_. Prices for Treasury FRNs are quoted in a specific way, which we will discuss in the next lecture.
"""

# ╔═╡ 69d8c85f-3735-4bd2-bd37-1ddadab87140
md"""
>- How to get there on the Bloomberg terminal?
>  - From the `Description` page where you are currently at, type `GP` and press enter.
"""

# ╔═╡ cf1fa1d8-da24-4f48-8762-affa1f58279a
md"""
# Treasury Inflation Protected Securities (TIPS)
- First issued in 1997 by the U.S. Treasury.
- Maturities of 5, 10, and 30 years.
- TIPS pay interest every six months up to and including the maturity date. At maturity, Treasury notes pay back their par value.
  - Similar to Treasury notes and bonds.
- Key difference is that both par value and interest go up with the rate of inflation.
"""

# ╔═╡ 3000e0f6-381f-4a9c-85c1-c517af617f14
md"""
- Why inflation matters and why one might want to hedge against inflation.
  - [WSJ, January 12, 2022: U.S. Inflation Hit 7% in December, Fastest Pace Since 1982](https://www.wsj.com/articles/us-inflation-consumer-price-index-december-2021-11641940760?mod=article_inline)
  - [WSJ, February 10, 2022: U.S. Inflation Rate Accelerates to a 40-Year High of 7.5%](https://www.wsj.com/articles/us-inflation-consumer-price-index-january-2022-11644452274?mod=hp_lead_pos1)
  - [WSJ, February 6, 2022: What Investors Should Know About TIPS](https://www.wsj.com/articles/tips-what-investors-should-know-treasury-inflation-protected-securities-11643849892?mod=hp_lista_pos1)
"""

# ╔═╡ 5c8f4910-7b54-414a-8eb9-52104c0ff36e
md"""
## Example of a Treasury TIPS
"""

# ╔═╡ 972e44da-4614-4349-bcb7-edb0518fe24d
LocalResource("./BloombergTIPS_01.png")

# ╔═╡ a1c74635-2fb9-492c-8243-4232b771718b
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `Treasury TIPS`.
>  - In the popup window,  select `TII Govt - United States Treasury Inflation Indexed Bonds (Multiple Matches)`.
>  - Next, click on one of the different Treasury bills in the list.
>  - Then, click on `DES` on the top-right, or type `DES` on the keyboard and press enter.
"""

# ╔═╡ 45ffcfef-16f3-464a-b868-0d3f64cb6019
md"""
##
"""

# ╔═╡ 874afd1d-eba3-4295-9f96-7502c187b171
md"""
- Let's look at price quotes for this Treasury TIPS.
- If you were to purchase this Treasury TIPS, would you pay \$105.28?
- The answer is _no_. Prices for Treasury TIPS are quoted in a specific way, which we will discuss in the next lecture.
"""

# ╔═╡ 95110a89-1d2b-4c83-9b1c-d7dc95ab89c8
LocalResource("./BloombergTIPS_02.png")

# ╔═╡ aa70d2f6-c726-45cc-89cb-bb6afb85f065
md"""
>- How to get there on the Bloomberg terminal?
>  - From the `Description` page where you are currently at, type `GP` and press enter.
"""

# ╔═╡ d69cce2c-dce4-4369-b3db-968c0b4d3dc6
md"""
## Inflation-Linked notes date back centuries
"""

# ╔═╡ ccba5159-b6bb-4c98-8f04-8dd91c032146
md"""
> Both Principal and Interest to be paid in the then current Money of said State, in a greater or less Sum, according as Five Bushels of Corn, Sixty-eight Pounds and four-seventh Parts of a Pound of Beef, Ten Pounds of Sheeps Wool, and Sixteen Pounds of Sole Leather shall then cost more or less than One Hundred and Thirty Pounds current Money, at the then current Prices of said Articles.
_Source: “Inflation-indexed Securities: Bonds, Swaps and Other Derivatives”, 2nd Edition, M. Deacon, A. Derry, D. Mirfendereski, Wiley._


"""

# ╔═╡ f50d144b-6d62-4b3f-b85a-d76861ea2ae0
LocalResource("./SoldiersDepreciationNote.svg",:width => 900)

# ╔═╡ c4aa9ab9-5502-4676-8b6a-5b55cc645e03
md"""
## TIPS Inflation-Adjustment
"""

# ╔═╡ f481451a-6949-4604-811b-6b4c530fd644
LocalResource("./TIPSInflationAdjustment.svg",:width => 900)

# ╔═╡ 992074c6-d6d5-4417-9edc-0229a0333070
md"""
# Treasury STRIPS

- The Treasury does not issue zero-coupon notes or bonds.
- However, because of the demand for zero-coupon instruments with no credit risk, the private sector has created such securities.
- The process of separating the interest on a bond from the underlying principal is called coupon stripping
- Zero-coupon Treasury securities were first created in August 1982 by large Wall-Street firms.
  - The problem with these securities was that they were identified with particular dealers and therefore reduced liquidity.
  - Moreover, the process involved legal and insurance costs. 
  - Today, all Treasury notes and bonds (fixed-principal and inflation-indexed) are eligible for stripping. 
- The zero-coupon Treasury securities created under the STRIPS program are direct obligations of the U.S. government
"""

# ╔═╡ cc282e0d-9faa-4808-b506-335e9097f2fe
md"""
## Treasury STRIPS in Bloomberg
"""

# ╔═╡ d44298e3-5763-4249-8140-5eefb80adb49
LocalResource("./TreasurySTRIPSBloomberg.png",:width => 900)

# ╔═╡ 57759a33-f026-4c15-91ba-f6af45627f1e
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `Treasury STRIP`.
>  - In the popup window,  select `S Govt - United States Treasury Strip Coupon (Multiple Matches)`.
>  - Next, click on one of the different Treasury bills in the list.
>  - Then, click on `DES` on the top-right, or type `DES` on the keyboard and press enter.
"""

# ╔═╡ 9c596473-76f6-4e9a-b3dd-32add39eaf92
md"""
##
"""

# ╔═╡ 9db71771-d778-4d43-af7a-80d8cfff97ff
LocalResource("./BloombergSTRIPS_01.png")

# ╔═╡ 36678746-8926-451d-b692-b57c620170c5
md"""
##
"""

# ╔═╡ 8f65e51f-01d6-4d02-bee2-f7d16f62a6c2
md"""
- Let's look at price quotes for this Treasury STRIPS.
"""

# ╔═╡ e16d631b-befe-4657-ad03-e65b5999e49a
LocalResource("./BloombergSTRIPS_02.png")

# ╔═╡ 0f801b78-6b89-48f4-ad96-e7336094e024
md"""
# Treasury Auctions
"""

# ╔═╡ c1165da4-1149-42d2-8841-a38d7cbc131d
LocalResource("./WSJ_TreasuryAuctionHeadline.png",:width => 900)

# ╔═╡ 7759dee0-da42-4796-ae60-e8bbe507f52e
md"""
_Source_: The Wall Street Journal, March 10, 2021.\
[Link to Article](https://www.wsj.com/articles/flood-of-new-debt-tests-bond-market-11615372201?mod=Searchresults_pos15&page=2)
"""

# ╔═╡ a8973960-ab9f-435b-a089-a6da9b4e24ec
LocalResource("./WSJ_TreasuryAuctionSizes.svg",:width => 900)

# ╔═╡ db0a2d77-11b1-4f54-819c-d43b0e18002b
md"""
## Treasury Auctions Basics

- Treasury securities are sold in the primary market through sealed-bid auctions.
- Each auction is **announced** several days in advance by means of a Treasury Department press release or press conference.
- The **announcement** provides details of the offering, including the _offering amount_ and the _term_ and _type_ of security being offered, and describes some of the auction rules and procedures.
"""

# ╔═╡ bb28a8c2-aaa8-4400-8601-514e156a9fe6
md"""
> Where to get information about the Treasury auction process?
> - Go to [TreasuryDirect.gov](https://www.treasurydirect.gov/)
> - In the middle panel, you see multiple links to resources about Treasury auctions.
> - For example, to learn about the auction process, click on `How Treasury auctions work`
"""

# ╔═╡ c3a14721-d694-4302-b8b2-adf887e6fb7d
LocalResource("./TreasuryDirect_Auctions_01.png")

# ╔═╡ 03393752-d39f-45a3-8157-520f361058ab
md"""
## Treasury Auction Announcement
"""

# ╔═╡ fea57e60-5e7b-4b5d-84a3-f16ca0279799
LocalResource("./TreasuryAuctionAnnouncement.png",:width => 900)

# ╔═╡ 0608bb54-8495-4365-810c-5f9010f0eed6
md"""
[Treasury Auction Announcements](https://www.treasurydirect.gov/instit/annceresult/press/press_secannpr.htm)
"""

# ╔═╡ c85dc38a-af8c-4c79-821c-2e9c90399318
md"""
## Treasury Auction Process

- The auction for Treasury securities is conducted on a competitive bid basis. 
- There are two types of bids that may be submitted by a bidder: 
  - noncompetitive bids 
  - competitive bids
- A noncompetitive bid is submitted by an entity that is willing to purchase the auctioned security at the yield that is determined by the auction process

"""

# ╔═╡ c1c539c2-afe1-41f4-9c26-29b5a0acfba1
md"""
## Noncompetitive Bids
- When a noncompetitive bid is submitted, the bidder only specifies the **quantity** sought.
  - The quantity in a noncompetitive bid may not exceed $5 million.
- For more information, visit  [How Treasury Auctions Work](https://www.treasurydirect.gov/instit/auctfund/work/work.htm).
"""

# ╔═╡ 35f529cd-9642-4bd9-a2f7-90018d1936be
md"""
## Treasury Auction Results - Noncompetitive Bids
"""

# ╔═╡ 094387ed-e45a-4d07-a4e6-0d3f08fda046
LocalResource("./TreasuryAuctionResultsNoncompetitive.png",:width => 900) 

# ╔═╡ 43e798f2-a8de-4920-9e44-9c56ba965670
md"""
## Competitive Bids
- A competitive bid specifies both the **quantity** sought _and_ the **yield** at which the bidder is willing to purchase the auctioned security.
- The competitive bids are then arranged from the __lowest yield__ bid to the __highest yield__ bid submitted.
  - The highest yield accepted by the Treasury is referred to as the **stop-out yield** (or **high yield**).
"""

# ╔═╡ d8e7db96-9471-424d-a616-2c1327d23c77
md"""
## Treasury Auction Results - Competitive Bids
"""

# ╔═╡ 96a2e1f6-b15d-446f-8828-c4c099fca07d
LocalResource("./TreasuryAuctionResultsCompetitive.png",:width => 900) 

# ╔═╡ 940baa2d-4117-4961-95a9-2043f3adc374
md"""
## [Additional Treasury Auction information](https://www.treasurydirect.gov/instit/auctfund/work/work.htm)
"""

# ╔═╡ a84b0684-0388-47ac-a338-2a52b5254a75
LocalResource("./TreasuryWhenIssuedTrading.png",:width => 1200) 


# ╔═╡ 57e22195-f876-4bab-a346-c1221a7607a3
md"""
## Auction Schedule

[Upcoming Treasury Auctions](http://www.treasury.gov/resource-center/data-chart-center/quarterly-refunding/Documents/auctions.pdf)
"""

# ╔═╡ 7792e937-3487-4d29-b2ba-c1b1d335e4b0
md"""
|                       Instrument                      	|              Auction Frequency             	|
|:-----------------------------------------------------:	|:------------------------------------------:	|
|                      4-week Bills                     	|             Weekly   (Tuesdays)            	|
|               13-week Bills               	|             Weekly   (Mondays)             	|
|               26-week Bills               	|             Weekly   (Mondays)             	|
|                     52-week Bills                     	|         Every   4 weeks (Tuesdays)         	|
|                      2-year Notes                     	|          Monthly   (End of month)          	|
|                      3-year Notes                     	|         Monthly   (Middle of month)        	|
|                      5-year Notes                     	|          Monthly   (End of month)          	|
|                      7-year Notes                     	|          Monthly   (End of month)          	|
|                     10-year Notes                     	|         Monthly   (Middle of month)        	|
|                     30-year Bonds                     	|         Monthly   (Middle of month)        	|
| 5-year TIPS  	|   Three times per year (Apr, Aug, Dec)   	|
|                      10-year TIPS                     	| Bimonthly   (Jan, Mar, May, Jul, Sep, Nov) 	|
|                      30-year TIPS                     	|   Three   times per year (Feb, Jun, Oct)   	|
|            2-year FRN             	|          Monthly   (End of month)          	|
"""

# ╔═╡ f2324049-7f96-4ad6-9eb6-6f8856fdf6fc
md"""
## Treasury Auction Example
"""

# ╔═╡ 22e9ecfc-72c3-43e1-9214-b907c5cd7d07
md"""
- Treasury Department announces a \$11 billion offering.
- There are \$1 billion in noncompetitive bids received. 
- Thus, there is \$11 - $1 = \$10 billion left to be allocated to competitive bidders.
- Suppose 6 competitive bidders submit the following sealed bids.
"""

# ╔═╡ 86254e63-de75-42c9-9b1e-e0a414cd0f63
md"""
| Name     	| Yield 	| Amount       	|
|----------	|-------	|--------------	|
| Bidder 1 	| 2.998% 	| \$3.5 billion 	|
| Bidder 2 	| 2.999% 	| \$2.5 billion 	|
| Bidder 3 	| 3.000% 	| \$3.0 billion   	|
| Bidder 4 	| 3.000% 	| \$3.0 billion   	|
| Bidder 5 	| 3.001% 	| \$2.0 billion   	|
| Bidder 6 	| 3.002% 	| \$1.0 billion   	|

**Question**: What do Bidder 1 to Bidder 6 get awarded in the auction?
"""

# ╔═╡ adeb0d3f-602d-4401-8a15-09b8d885ef40
md"""
##
"""

# ╔═╡ 290c5c6d-f2ab-4707-a298-99e9d678a72e
md"""
→ The Treasury works its way down the list of competitive bids and accepts the total amount submitted at the lowest possible bid yields (hightest prices) until the full offering amount has been awarded.
"""

# ╔═╡ 785bff43-7920-494d-b59c-2fa6c8cd2391
md"""
| Name     	| Yield 	| Amount Bid   	| Amount Awarded   |  Competitive Amount  |
|----------	|-------	|--------------	| ---------------- |  ------------------- |
|           |           |               |                  |  **\$10 billion**    	  |
| Bidder 1 	| 2.998% 	| \$3.5 billion |                  |  -\$3.5 billion      |   
|    	 	| 		 	| 				|                  |  **\$6.5 billion**   |   
| Bidder 2 	| 2.999% 	| \$2.5 billion |                  |  -\$2.5 billion      |
|    	 	| 		 	| 				|                  |  **\$4.0 billion**   |   
"""

# ╔═╡ 6a64ec0a-6f67-428c-afbf-b67a4ae3568b
md"""
##
"""

# ╔═╡ 1a7a0375-507e-4a5b-befc-c88208ab8394
md"""
- At this point there are \$4 billion remaining for competitive bidding.
- However, there are a total of \$6 billion in bids at the next lowest rate (3.000%) by Bidder 3 and Bidder 4.
- The highest accepted rate (3.000%) is known as the **stop-out rate**.
- In this case, each bidder at this rate is awarded a percentage of their total bid amount. 
  - The **allocation percentage** is calculated by dividing the remaining competitive offering by the total amount bid at the stop-out rate.

$$\frac{\textrm{Remaining Comptetitive Offering}}{\textrm{Total Bids at Stop-Out Rate}} = \frac{\$4 \textrm{ billion}}{\$6\textrm{ billion}} = 66.7\%$$

- Bidder 3 and Bidder 4 each get a partial allocation of \$2 billion (66.67% x \$3.0 billion)
"""

# ╔═╡ 9c1a34f3-2ad5-4f14-b77b-a941fdff79bf
md"""
##
"""

# ╔═╡ 12aea81d-c470-4fd5-b769-46040c3676e2
md"""
|        Name       	|     Yield    	|       Amount Bid      	|     Amount awarded    	|     Allocation percentage    	|     Rate awarded    	|
|:-----------------:	|:------------:	|:---------------------:	|:---------------------:	|:----------------------------:	|:-------------------:	|
|     Bidder   1    	|     3.00%    	|     \$3.5   billion    	|     \$3.5   billion    	|              100%            	|         3.00%       	|
|     Bidder   2    	|     3.00%    	|     \$2.5   billion    	|     \$2.5   billion    	|              100%            	|         3.00%       	|
|     Bidder   3    	|     3.00%    	|     \$3.0   billion    	|     \$2.0   billion    	|             66.67%           	|         3.00%       	|
|     Bidder   4    	|     3.00%    	|     \$3.0   billion    	|     \$2.0   billion    	|             66.67%           	|         3.00%       	|
|-----------------	|------------	|---------------------	|---------------------	|----------------------------	|-------------------	|
|     Bidder   5    	|     3.00%    	|     \$2.0   billion    	|           \$0          	|               0%             	|          N/A        	|
|     Bidder   6    	|     3.00%    	|     \$1.0   billion    	|           \$0          	|               0%             	|          N/A        	|
"""

# ╔═╡ 4694dcaf-e8c4-4c99-9020-25f7227c4fd3
md"""
## General Auction Timing
[General Auction Timing](https://www.treasurydirect.gov/instit/auctfund/work/auctime/auctime.htm)
"""

# ╔═╡ 53c77ef1-899d-47c8-8a30-ea38380d1614
md"""
## Wrap-Up
"""

# ╔═╡ 670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
begin
	html"""
	<fieldset>      
        <legend>Our goals for today</legend>      
		<br>
        <input type="checkbox" value="" checked>Know the different types of securities issued by the U.S. Department of the Treasury<br>      
		<br>
        <input type="checkbox" value="" checked>Be familiar with the Treasury auction process.
<br>
<br>
	  	</fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
# Reading 
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 7
"""

# ╔═╡ 25448e4a-345b-4bd6-9cdb-a6a280cfd22c
#Set-up packages
begin
	
	using DataFrames, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, XLSX
	
	gr();
	Plots.GRBackend()


	#Define html elements
	nbsp = html"&nbsp" #non-breaking space
	vspace = html"""<div style="margin-bottom:0.05cm;"></div>"""
	br = html"<br>"

	#Sets the width of cells, caps the cell width by 90% of screen width
	#(setting overwritten by cell below)
	# @bind screenWidth @htl("""
	# 	<div>
	# 	<script>
	# 		var div = currentScript.parentElement
	# 		div.value = screen.width
	# 	</script>
	# 	</div>
	# """)

	
	# cellWidth= min(1000, screenWidth*0.9)
	# @htl("""
	# 	<style>
	# 		pluto-notebook {
	# 			margin: auto;
	# 			width: $(cellWidth)px;
	# 		}
	# 	</style>
	# """)
	

	#Sets the width of the cells
	#begin
	#	html"""<style>
	#	main {
	#		max-width: 900px;
	#	}
	#	"""
	#end


	#Sets the height of displayed tables
	html"""<style>
		pluto-output.scroll_y {
			max-height: 550px; /* changed this from 400 to 550 */
		}
		"""
	

	#Two-column cell
	struct TwoColumn{A, B}
		left::A
		right::B
	end
	
	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
		write(io,
			"""
			<div style="display: flex;">
				<div style="flex: 50%;">
			""")
		show(io, mime, tc.left)
		write(io,
			"""
				</div>
				<div style="flex: 50%;">
			""")
		show(io, mime, tc.right)
		write(io,
			"""
				</div>
			</div>
		""")
	end

	#Creates a foldable cell
	struct Foldable{C}
		title::String
		content::C
	end
	
	function Base.show(io, mime::MIME"text/html", fld::Foldable)
		write(io,"<details><summary>$(fld.title)</summary><p>")
		show(io, mime, fld.content)
		write(io,"</p></details>")
	end
	
	
	#helper functions
	#round to digits, e.g. 6 digits then prec=1e-6
	roundmult(val, prec) = (inv_prec = 1 / prec; round(val * inv_prec) / inv_prec); 

	using Logging
	global_logger(NullLogger())
		
	display("")
end

# ╔═╡ d1eeef07-bb88-4402-9b09-d27061ec065a
png_joinpathsplit__FILE__1assetsdownloadpng = let
    import PlutoUI
    PlutoUI.LocalResource(joinpath(split(@__FILE__, '#')[1] * ".assets", "download.png"))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.3.1"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.25.3"
PlutoUI = "~0.7.27"
XLSX = "~0.7.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "49f14b6c56a2da47608fe30aed711b5882264d7a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.11"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ae13fcbc7ab8f16b0856729b050ef0c446aa3492"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.4+0"

[[EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7e4920a7d4323b8ffc3db184580598450bde8a8e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.7"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8979e9802b4ac3d58c503a20f2824ad67f9074dd"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.34"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "15dfe6b103c2a993be24404124b8791a09460983"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.11"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a635a9333989a094bddc9f940c04c549cd66afcf"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.4"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "96d05d01d6657583a22410e3ba416c75c72d6e1d"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.8"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─a2f22b9d-13f8-4e39-b7dd-14b905d987ab
# ╠═25448e4a-345b-4bd6-9cdb-a6a280cfd22c
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─69dca09e-b572-436f-90c6-187af17cf027
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─10a73b76-b6ad-4081-b8b1-21363608618e
# ╟─42f7e15d-9abc-40ca-bd70-7131957907a5
# ╟─b33e1473-e374-441b-a6a4-6c2a7b079c98
# ╟─7bb29c12-c0a0-4eb0-a4d6-bd9c52443751
# ╟─f89f6fc4-cb6f-4d7b-84c9-f8a18e764427
# ╠═313959e0-eea6-449a-a6b8-29c9394e50b6
# ╟─e20b95fa-e038-4d3b-82ca-8a38262c64c4
# ╟─2bf62523-a0f1-400e-9178-79062e0a171e
# ╟─206df1a6-bf12-4957-93f7-472ee89594c4
# ╟─c8f703dc-5a1c-4c39-b9a4-c3dd0a2806d8
# ╟─13a58974-2ae8-4596-933f-5d2b5b8f5a23
# ╟─c7b5fcd2-a727-4bde-aae3-cd39dfb9a43b
# ╟─e89beeee-1ad9-4440-ba95-9bd0eb6bfe72
# ╟─7f91ba74-ccca-4f08-8252-9de7f956b285
# ╟─84009ee2-cfc3-437c-8782-d370b8b8c4f6
# ╟─a2df8dc1-f6da-4816-85b9-c7caadc03584
# ╟─5db80dee-c643-4cc1-bca4-00b1ffd0a948
# ╟─0357258e-8133-4ef3-946f-5134a9560b9d
# ╟─ae67f236-60ec-4c2e-abd3-9ea537200ca3
# ╟─fa1dcebd-4a54-433b-897c-de2929fb8233
# ╟─2452e56b-2a61-4608-9ca0-55c8cdca89c6
# ╟─f688e93c-e8b1-4718-b56e-d76bf70eef57
# ╟─4914c857-5dc8-43b8-8e70-377debbc3d0c
# ╟─d25744ad-fbe3-4f08-b17a-d00d51bcb2b8
# ╟─382a9c58-4baa-4ad2-9f32-7189d4881c50
# ╟─deb54591-8769-480d-98ad-32157abac2c0
# ╟─3578793a-e0b6-42de-941b-2db09ef99e49
# ╟─82db2847-a1a1-45a3-8d29-c3ac4213591c
# ╟─adbc8a60-c33c-44ba-a284-fa7b676b9618
# ╟─1a6add34-52e1-4663-9228-f0fca63f8cc2
# ╟─8de081f6-2b7f-4d03-b565-b4ac01c2773e
# ╟─d296b99d-588d-48ac-8e0c-a0bcbde72c56
# ╟─1c4db2fa-7187-4966-aa3f-9a7f56036497
# ╠═3a3b7641-ed63-4cce-a98c-a4cf1b6e603d
# ╟─2384b88b-e8dc-4e9c-9488-27828da0289d
# ╟─0918383a-9a0b-4f8c-ba63-aaad1cf6d72c
# ╟─c9b876e2-cb29-4a70-9c1f-abb2dedf3fe2
# ╟─d912c3cb-c1a6-46fe-af9d-25a75074b31d
# ╟─40df1177-48cf-4cb2-9860-11d2d9f0a450
# ╟─4567e3a2-24fb-494f-8005-801b03ffeabf
# ╟─76774fcb-f806-4db2-b653-fe69720f43a7
# ╟─a440a28f-04af-4248-8f2b-c8e6a726c07a
# ╟─fef5577e-025f-4afc-9fd9-aa025146858e
# ╟─90883b07-064f-4395-a805-ddaaad7f97fd
# ╟─faecc806-5f33-49c6-a463-b349cbfb8acc
# ╟─c7a254a6-d877-4de0-a3e5-a64fb93ae079
# ╟─9b53686c-e362-46c5-bdd9-0c388d9cd122
# ╟─9d0017a5-6b7b-4c1b-9323-7a8fdc54db77
# ╟─69d8c85f-3735-4bd2-bd37-1ddadab87140
# ╟─cf1fa1d8-da24-4f48-8762-affa1f58279a
# ╟─3000e0f6-381f-4a9c-85c1-c517af617f14
# ╟─5c8f4910-7b54-414a-8eb9-52104c0ff36e
# ╠═972e44da-4614-4349-bcb7-edb0518fe24d
# ╟─a1c74635-2fb9-492c-8243-4232b771718b
# ╟─45ffcfef-16f3-464a-b868-0d3f64cb6019
# ╟─874afd1d-eba3-4295-9f96-7502c187b171
# ╟─95110a89-1d2b-4c83-9b1c-d7dc95ab89c8
# ╟─aa70d2f6-c726-45cc-89cb-bb6afb85f065
# ╟─d69cce2c-dce4-4369-b3db-968c0b4d3dc6
# ╟─ccba5159-b6bb-4c98-8f04-8dd91c032146
# ╟─f50d144b-6d62-4b3f-b85a-d76861ea2ae0
# ╟─c4aa9ab9-5502-4676-8b6a-5b55cc645e03
# ╟─f481451a-6949-4604-811b-6b4c530fd644
# ╟─992074c6-d6d5-4417-9edc-0229a0333070
# ╟─cc282e0d-9faa-4808-b506-335e9097f2fe
# ╟─d44298e3-5763-4249-8140-5eefb80adb49
# ╟─57759a33-f026-4c15-91ba-f6af45627f1e
# ╟─9c596473-76f6-4e9a-b3dd-32add39eaf92
# ╟─9db71771-d778-4d43-af7a-80d8cfff97ff
# ╟─36678746-8926-451d-b692-b57c620170c5
# ╟─8f65e51f-01d6-4d02-bee2-f7d16f62a6c2
# ╟─e16d631b-befe-4657-ad03-e65b5999e49a
# ╟─0f801b78-6b89-48f4-ad96-e7336094e024
# ╟─c1165da4-1149-42d2-8841-a38d7cbc131d
# ╟─7759dee0-da42-4796-ae60-e8bbe507f52e
# ╟─a8973960-ab9f-435b-a089-a6da9b4e24ec
# ╟─db0a2d77-11b1-4f54-819c-d43b0e18002b
# ╟─bb28a8c2-aaa8-4400-8601-514e156a9fe6
# ╟─c3a14721-d694-4302-b8b2-adf887e6fb7d
# ╟─03393752-d39f-45a3-8157-520f361058ab
# ╟─fea57e60-5e7b-4b5d-84a3-f16ca0279799
# ╟─0608bb54-8495-4365-810c-5f9010f0eed6
# ╟─c85dc38a-af8c-4c79-821c-2e9c90399318
# ╟─c1c539c2-afe1-41f4-9c26-29b5a0acfba1
# ╟─35f529cd-9642-4bd9-a2f7-90018d1936be
# ╟─094387ed-e45a-4d07-a4e6-0d3f08fda046
# ╠═d1eeef07-bb88-4402-9b09-d27061ec065a
# ╟─43e798f2-a8de-4920-9e44-9c56ba965670
# ╟─d8e7db96-9471-424d-a616-2c1327d23c77
# ╟─96a2e1f6-b15d-446f-8828-c4c099fca07d
# ╟─940baa2d-4117-4961-95a9-2043f3adc374
# ╟─a84b0684-0388-47ac-a338-2a52b5254a75
# ╟─57e22195-f876-4bab-a346-c1221a7607a3
# ╟─7792e937-3487-4d29-b2ba-c1b1d335e4b0
# ╟─f2324049-7f96-4ad6-9eb6-6f8856fdf6fc
# ╟─22e9ecfc-72c3-43e1-9214-b907c5cd7d07
# ╟─86254e63-de75-42c9-9b1e-e0a414cd0f63
# ╟─adeb0d3f-602d-4401-8a15-09b8d885ef40
# ╟─290c5c6d-f2ab-4707-a298-99e9d678a72e
# ╟─785bff43-7920-494d-b59c-2fa6c8cd2391
# ╟─6a64ec0a-6f67-428c-afbf-b67a4ae3568b
# ╟─1a7a0375-507e-4a5b-befc-c88208ab8394
# ╟─9c1a34f3-2ad5-4f14-b77b-a941fdff79bf
# ╟─12aea81d-c470-4fd5-b769-46040c3676e2
# ╟─4694dcaf-e8c4-4c99-9020-25f7227c4fd3
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
