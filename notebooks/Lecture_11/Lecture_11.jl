### A Pluto.jl notebook ###
# v0.19.0

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

# ╔═╡ f0545c67-5cfd-438f-a9ef-92c35ebaefa4
#Set-up packages
begin
	
	using DataFrames, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, ShortCodes
	
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

# ╔═╡ 41d7b190-2a14-11ec-2469-7977eac40f12
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
	<div align=center style="font-size:25px; font-family:family:Georgia">Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> The TIPS-Treasury Bond Puzzle</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:1cm"> </p>
	"""
end

# ╔═╡ 6498b10d-bece-42bf-a32b-631224857753
md"""
# Overview
"""

# ╔═╡ 95db374b-b10d-4877-a38d-1d0ac45877c4
begin
	html"""
	<fieldset>      
        <legend>Outline</legend>      
		<br>    
		<input type="checkbox" value="">The U.S. Treasury Bond Puzzle<br><br>
		<input type="checkbox" value="">Treasury TIPS<br><br>
		<input type="checkbox" value="">Inflation Swaps<br><br>
		<input type="checkbox" value="">TIPS-Treasury Trading Strategy<br><br>
	</fieldset>      
	"""
end

# ╔═╡ d2908a7c-51af-431c-ac09-4a7d89dbf02f
TableOfContents(aside=true, depth=1)

# ╔═╡ 886da2d4-c1ec-4bb4-8733-e3b46c95dd36
md"""
# The TIPS-Treasury Bond Puzzle
"""

# ╔═╡ 6334202e-2047-4e7c-beca-020768340f08
md"""
# The Largest Arbitrage Ever Documented

> - _“... you can forget about the concept of picking up pennies in front of a steamroller because ... this **arbitrage** can run to as much **$20 per $100 notional amount**.”_\
> - _“The trade was Barnegat’s most profitable and saw the fund make an impressive **132 per cent return that year**, outpacing almost every other fund in the industry.”_

Sources: [The largest arbitrage ever documented](https://www.ft.com/content/3ec205b7-4351-3c0b-a46c-e23ab86c3a44); [Hedge funds reap rewards from Treasuries](https://www.ft.com/content/a5aa3c38-c111-11df-afe0-00144feab49a)
"""

# ╔═╡ 98f202ba-7720-40fd-b618-87bd30de840c
md"""
##
"""

# ╔═╡ 410b6e69-0ebc-4e2f-9b07-48b7f112ab83
md"""
> - _**“For Barnegat the opportunity was clear: the fund bought TIPS bonds and went short on regular Treasury bonds of a matched maturity, hedging out the effect of inflation along the way with a swap contract.”**_ \
> - _“The result was a trade that would make money if the divergent prices between the two securities converged. The difference in price between the two securities narrowed sharply through 2009.”_\
> - _“ 'If 2009 was an excellent year, then 2010 is still a very good year. The opportunities are huge in some cases,' says Mr Treue. Indeed, Barnegat is up 15.75 per cent so far this year.”_

Source: [Hedge funds reap rewards from Treasuries](https://www.ft.com/content/a5aa3c38-c111-11df-afe0-00144feab49a)
"""

# ╔═╡ 8f8c2c95-25ef-4da0-afe1-b0a204911aeb
md"""
##
"""

# ╔═╡ 70e71241-e939-4b06-bcbe-ff7cf611df7a
md"""
[Presentation by Bob Treue, Fixed Income Arbitrage, Barnegat Fund Management](https://youtu.be/V-ssGaTnl8o)
"""

# ╔═╡ 3e8baccf-799d-4694-99b0-9612bc59928f
YouTube("V-ssGaTnl8o")

# ╔═╡ 355989df-4aab-4c82-9e43-67123e9aecee
md"""
# The TIPS-Treasury Bond Puzzle in the Journal of Finance
"""

# ╔═╡ 9185f93e-3503-4dff-8133-8afd36fe148b
md"""
> _"It’s contained in a great little paper published earlier this month and it isn’t a fancy, schmancy accessible to high frequency traders only type of trade."_

Source: [Kaminska (2010), FT.com](https://www.ft.com/content/3ec205b7-4351-3c0b-a46c-e23ab86c3a44)
"""

# ╔═╡ fce5cf58-d66c-4fde-b6bb-854f745d1935
md"""
##
"""

# ╔═╡ 8fa726b4-7064-4bd3-a2fa-54d875593009
LocalResource("./Assets/FleckensteinLongstaffLustig2014_Abstract.svg",:width => 900)

# ╔═╡ 675daf21-167e-43a2-b680-a905aaaf1563
md"""
# International Inflation-Linked Bond Puzzle
> - _Italian bond markets, for example, exhibited unprecedented price discrepancies between different classes of bond issued by the government as a result of the ECB’s LTRO liquidity injection._\
> - _In January, investors dumped inflation-protected Italian bonds, fearful that they would automatically drop out of key European bond indices if the country’s credit rating was downgraded, while at the same time Italian banks snapped up regular Italian bonds with LTRO cash._\
> - **_Hedge funds bought the cheap inflation-protected bonds, wrote swaps to offset inflation and then shorted expensive regular Italian bonds, thereby completely hedging out credit risk and inflation and locking in the supply and demand-driven difference between the two bonds._**\
> - _The spread between them was more than 200 basis points, according to Bob Treue, the founder of Barnegat, a US-based fixed income arbitrage hedge fund that has made 18 per cent on its investments so far this year._
Source: [ECB liquidity fuels high stakes hedging](https://www.ft.com/content/cb74d63a-7e75-11e1-b009-00144feab49a#axzz24lB77mEm)
"""

# ╔═╡ 298dada3-f3a7-4ac1-bdaa-55be8b359e95
md"""
## Treasury Inflation Protected Securities (TIPS)
- First issued in 1997 by the U.S. Treasury.
- Maturities of 5, 10, and 30 years.
- TIPS pay interest every six months up to and including the maturity date. At maturity, Treasury notes pay back their par value.
  - Similar to Treasury notes and bonds.
- Key difference is that the par value of a TIPS goes up with the rate of inflation.

[Link to Treasury](https://www.treasurydirect.gov/indiv/products/prod_tips_glance.htm)
"""

# ╔═╡ dc307a3f-c258-49cd-bb46-499da5209f41
md"""
##
"""

# ╔═╡ d6729dc9-0706-4405-9786-0da8ef96fe0a
#US Treasury Market
begin
	TreasMkt = DataFrame()
	plot_Treas = plot()
	let
		data_url = "https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/US-Treasury-Securities-Statistics-SIFMA_Outstanding.csv"
		my_file = CSV.File(HTTP.get(data_url).body; missingstring="-999")
		# my_file = CSV.File("./Assets/US-Treasury-Securities-Statistics-SIFMA_Outstanding.csv")
 		TreasMkt = DataFrame(my_file)
		
		transform!(TreasMkt, [:Notes,:Bonds] => (+) => :NotesAndBonds)
		transform!(TreasMkt, 
		  [:TIPS, :Total] => ByRow( (x,y)->any(ismissing.([x,y])) ? 
		 		missing :  (x/y*100)) => :TIPSPctTreas)
		
		minX = 1997
		maxX = 2020
		minY = 0.0
		maxY = 2000.0
		plot!(plot_Treas, TreasMkt.Year,TreasMkt.TIPS, 
		  	xlim=(minX,maxX), ylim=(minY, maxY), 
		  	ylabel="Billions of Dollars",label="TIPS",
		  	legend = :topleft, title="Amount Outstanding",right_margin = 15Plots.mm)	
		subplot=twinx()
		plot!(subplot, TreasMkt.Year,TreasMkt.TIPSPctTreas, color=:red,
			xlim=(minX,maxX), ylim=(0,20), ylabel = "Percent", 
			yticks=(0:5:20),label = "TIPS to Treasury Debt")	
		plot(plot_Treas)
	end
end

# ╔═╡ 6bd410dd-f851-48d9-a4f8-9ffff975c7a3
md"""
# Inflation-Linked Securities
"""

# ╔═╡ 3e5097fe-5a26-4326-bbcd-1ae95a163c02
md"""
## Historical Background
"""

# ╔═╡ 9e730ef8-2791-4fd7-bd07-8844cd3c2f69
md"""
- There is a long history of countries issuing inflation-linked debt. 
"""

# ╔═╡ fd4f618a-71f2-4976-8515-031e79df3e5b
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/SoldiersDepreciationNote.png",:width => 900)

# ╔═╡ 400ee234-919e-4309-8a9a-208df0926d44
md"""
##
"""

# ╔═╡ 448aef9e-7b85-4b8f-ba40-7490513dfd1a
md"""
> Both Principal and Interest to be paid in the then current Money of said State, in a greater or less Sum, according as Five Bushels of Corn, Sixty-eight Pounds and four-seventh Parts of a Pound of Beef, Ten Pounds of Sheeps Wool, and Sixteen Pounds of Sole Leather shall then cost more or less than One Hundred and Thirty Pounds current Money, at the then current Prices of said Articles.
_Source: “Inflation-indexed Securities: Bonds, Swaps and Other Derivatives”, 2nd Edition, M. Deacon, A. Derry, D. Mirfendereski, Wiley._


"""

# ╔═╡ 8b9ac326-884f-4d49-bb09-b01cfa0ae9d3
md"""
##
"""

# ╔═╡ 7e316df9-3c1d-47ca-96e7-e79984fc92cf
md"""
Emerging market countries started to issue inflation-linked bonds in the 1950s. 
- Much later, the United Kingdom’s Debt Management Office followed suit with the first inflation-linked gilt issue in 1981, followed by Australia, Canada, and Sweden. 
- The U.S. Treasury only started issuing Treasury Inflation-Protected Securities (TIPS) in **1997**. 
- Currently, France, Germany, and Italy are frequent issuers of inflation-linked bonds in the Euro area. Japan recently started issuing inflation-linked bonds again. Australia, Brazil, Canada, Chile, Israel, Mexico, Turkey, and South Africa also issue substantial amounts of inflation-linked bonds.
"""

# ╔═╡ cb6d785c-235d-4c8a-935e-17628c13e850
md"""
## Index-Linked Bonds
"""

# ╔═╡ 62c1c14e-7094-430a-bcff-74e298d6597e
md"""
- Treasury Inflation-Protected Securities (TIPS) are _index-linked_ bonds.
  - An index-linked bond is one whose _cash flows_ are linked to movements in a specific price index.
- The _principal amount_ of a TIPS is indexed to the price level. 
  - Since a fixed coupon rate is applied to the principal that varies with the price level, the actual coupon cash flows vary in response to the realized rate of inflation.
- Index-linked bonds are usually indexed to a broad measure of prices, typically a domestic _Consumer Price Index (CPI)_.
"""

# ╔═╡ abe6fa93-0105-43e5-9e03-92664b563b38
md"""
## U.S. Consumer Price Index
- In the U.S. this price index is the Consumer Price Index for All Urban Consumers (_CPI-U_).
- The CPI-U measures the level of prices paid by consumers for goods and services. 
- This index is published by the Bureau of Labor Statistics (BLS) every month.
- [Bureau of Labor Statistics](https://www.bls.gov/schedule/news_release/cpi.htm); [Bureau of Labor Statistics Release](https://www.bls.gov/news.release/pdf/cpi.pdf)
"""

# ╔═╡ 348219b8-8d4c-425b-8773-b42313554eef
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/USCPIYoY.svg",:width => 900)

# ╔═╡ 2ed83178-02a6-4e60-bd33-9df1a74b2f04
md"""
Source: [BLS.gov](https://www.bls.gov/charts/consumer-price-index/consumer-price-index-by-category-line-chart.htm)
"""

# ╔═╡ c3d5177e-5dc3-43da-a419-37b6e58ac49a
md"""
##
"""

# ╔═╡ 34d8c7f7-0266-49c8-aac5-ac882d3beb48
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/USCPI_ReleaseSchedule.svg",:width => 600)

# ╔═╡ 1b701e22-1766-4113-98e7-f6fc5f3f51f6
md"""
##
"""

# ╔═╡ 562de281-2571-4b1f-8363-fcbd02cb3204
md"""
### Inflation Adjustment

- A simple example is useful at this stage to clarify the concepts. 
- Suppose that an investor is faced with the choice between two instruments with the same maturity: 
  - Conventional bond yielding a _nominal_ yield of 5% 
  - Index-linked bond offering a _real_ yield of 3%. 
- The market’s valuations of these two bonds would imply that inflation is expected to be of the order of 2% per annum over their lifetime (5% - 3%=2%). 
- If the rate of inflation actually turns out to be higher at, say, 4% on average, then at maturity the indexed bond will have generated a 3% real return (precisely as expected). 
- The conventional bond’s 5% nominal return will have been eroded such that its ex post real yield is only 1%. 
- Of course, the reverse could occur instead. 
  - Suppose inflation turns out to be lower on average than had been expected at, say, 1%, then the conventional bond’s real return would turn out to be 4%, while that on the indexed bond would still have been 3%.
"""

# ╔═╡ 7a447118-1335-41a5-8f88-9f47a6637061
md"""
## TIPS Inflation-Adjustment Basics
"""

# ╔═╡ f0b795bd-a6fe-4f80-8b65-f345a5aeb953
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/TIPSInflationAdjustment.svg",:width => 900)

# ╔═╡ dca49c6a-a897-442e-8924-7b171e806fc5
md"""
## TIPS Inflation Adjustment
"""

# ╔═╡ b969b168-ec64-4a68-99bd-23b7067b0048
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/ReferenceCPI_Des.png",:width => 900)

# ╔═╡ 9ed05f91-a314-4e6c-b05c-8d372d0f2d0f
md"""
##
"""

# ╔═╡ 977ba39b-5e9d-4591-a5f0-3b6fc0b5fec4
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/ReferenceCPI_Graph.png",:width => 900)

# ╔═╡ a0af3215-6ecc-4083-afaa-31c476ebae4a
md"""
## TIPS Inflation Adjustment Details

- The principal amount of a TIPS (assume $100 at issuance) is adjusted daily based on the CPI-U. 
- The inflation adjustment $I_t$ is computed as the ratio of the **Reference CPI** at the time $t$ divided by the reference CPI when the TIPS was first issued ($t=0$). 
$$I_t = \frac{\textrm{Reference CPI at time } t}{\textrm{Reference CPI at TIPS issue date}}$$

- The **Reference CPI** for a particular date $t$ during a month is linearly interpolated from the **Reference CPI** for the beginning of that month and the **Reference CPI** for the beginning of the subsequent month.
  - The **Reference CPI** for the first day of _any_ calendar month is the CPI-U index for the third preceding calendar month. 
  - _Example 1_: the **Reference CPI** for _April 1_ is the CPI-U index for the month of _January_ (which is reported by the BLS during February).
  - _Example 2_: the **Reference CPI** for _April 15_ is roughly the average of the CPI-U index for the month of _January_ and the CPI-U index for the month of February.
- However, the dollar value of the TIPS principal value is bounded below at $100, its value at issuance. Hence, TIPS offer some deflation protection.

"""

# ╔═╡ 2b18e585-71de-4820-8a4a-d46af365789f
md"""
##
"""

# ╔═╡ 437de46e-78cd-4b83-9372-6a454c95d135
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/IndexationLag_Chart.svg",:width => 900)

# ╔═╡ 8c4b9294-568c-49bf-a760-c54da18de10d
md"""
## Reference CPI Calculation Example for January 25, 1997
- To find the **Reference CPI** for any date in Janurary 1997, we first find the **Reference CPI** index levels for January 1, 1997 and for February 1, 1997.
  - The **Reference CPI** level is the US CPI-U index from three months prior.
  - For January this is the CPI-U from October 1996 (published by the BLS in November) and for February this is the CPI-U from November 1996 (published by the BLS in December).
- Then, take the difference between the two index CPI-U index levels and divide by it by the actual number of days in the month.  
- Next, multiply the result by the number of the day for which the **Reference CPI** is to be calculated and subtract 1.
  - For example, January 7 would be 6. January 25 is 24.
- Finally, add this result to the January 1st, CPI-U index level.
"""

# ╔═╡ ae72b826-72a7-4c14-8ed6-c5c27f925dd5
md"""
##
"""

# ╔═╡ 2e76221f-cec2-443b-b1b4-cf44d93838b3
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/RefCPICalc1997.png",:width => 900)

# ╔═╡ 60b59241-c081-4da7-9a87-986d9e5931d1
md"""
##
"""

# ╔═╡ 3f620c75-69c9-461a-b8ec-396079c36088
md"""
> Jan 1 level = 158.3

> Feb 1 level = 158.6 

> 158.6 - 158.3 = .30 

> .30/31 days = .0096774 (there are 31 days in January)

> .0096774 $\times$ 6 = .05806 

> CPI-U for Jan 7 = 158.3 + .05806 = 158.35806. 
"""

# ╔═╡ beb4b354-3cd6-4a03-b161-0cb1c1845f0b
md"""
## Inflation Adjustment 
"""

# ╔═╡ b6c222b6-012b-42ea-967f-fe44a88123b9
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/of698cpi_crop.svg",:width => 500)

# ╔═╡ ff2e0417-8557-4fd7-b03e-0c5aae7882f3
md"""
- The Reference CPI is then turned into a ratio to caclulate the inflation adjustment by taking the Reference CPI on the date and dividing by the Reference CPI at issue. 
  - For example, CPI-U for Jan 15, the official issue date of the inaugural TIPS bond is 158.43548. 
  - The CPI-U for Jan 25 is 158.53226.
> The inflation adjustment factor for Jan 25 is 158.53226/158.43458 = 1.00061

"""

# ╔═╡ 0c8d7c37-6dcd-4a8b-b333-073a4a8e99ef
md"""
## Deflation Protection
- TIPS have an embedded option that protects against deflation.
- The Treasury guarantees that the _final redemption value is no less than \$100 per \$100 nominal_ amount, irrespective of the movements in the CPI over the life of the bond.
- Let $F$ be the TIPS principal amount and $T$ the time to maturity of the TIPS.
- The principal cash flow at maturity $T$ is
$$F \times \max\left[\, I_T, 1 \,\right]$$
- This deflation protection does not apply to coupon cash flows.
"""

# ╔═╡ 66a72bb1-64f1-4fd9-a6df-7d922758e4c4
md"""
## Example
"""

# ╔═╡ 9635fd8d-8ae6-424a-a1c1-803bf7c2dc78
md"""
- Let $F$ be the TIPS principal value.
- Let $c$ denote the (fixed) _real_ coupon rate on the TIPS.
- Let $T$ denote the time to maturity of the TIPS (in years).

"""

# ╔═╡ 6d047903-fa9e-47d4-9147-6518869cc074
md"""
- Principal $F$ [$]: $(@bind F Slider(100:100:1000, default=100, show_value=true))
- Real Coupon Rate c [%]: $(@bind c Slider(0:0.25:10, default=3, show_value=true))
- Time to Maturity $T$ [years]: $(@bind T Slider(1:1:30, default=5, show_value=true))
- Reference CPI at issue date: $(@bind I₀ Slider(100:1:300, default=100, show_value=true))
"""

# ╔═╡ cfa2509b-38ef-470e-8c49-481e3fdb3909
Markdown.parse("
- Suppose, \$c= $c \\%\$ and \$F=$F\$.
- In real terms, the coupon cash flows at each coupon date are 
		
\$\\frac{c}{2} \\, F = \\frac{$(c/100)}{2} \\, $F = $(c/200*F)\$
	
- Suppose there is inflation (or deflation).
- The actual cash flows (in nominal terms) of the TIPS are:
")


# ╔═╡ ac751d3e-0dcf-4859-a7b8-6185eeff4b6b
begin
	cfDates = collect(0.5:0.5:T)
	randNormal = randn(length(cfDates))
	refCPI = zeros(length(cfDates))
	refCPI[1] = I₀ + (1+randNormal[1])
	for ii=2:length(refCPI)
    	refCPI[ii] = refCPI[ii-1] + (0+randNormal[ii]);
	end
	Infl = (refCPI./I₀ .-1)*100
	IIₜ = refCPI./I₀
	adjPrin = F.*IIₜ
	adjPrin[end] = maximum([100,F.*IIₜ[end]])
	cfAmounts = (c/200)*F.*IIₜ.*vec(ones(length(cfDates),1))
	cfAmounts[end] = cfAmounts[end]+100*maximum([IIₜ[end],1])
	df = DataFrame(Time=cfDates, Reference_CPI=refCPI, Iₜ=IIₜ, Adjusted_Principal=adjPrin, Cashflows=cfAmounts,)
end

# ╔═╡ 6a4974ec-ec57-4e73-a61f-ad83958d2874
md"""
# Inflation Derivatives
In addition to the cash inflation market, there is an active derivatives market that consists mainly of inflation swap contracts and inflation options. The inflation swap market in the United States is growing rapidly.
"""

# ╔═╡ aef13d6b-d776-44cd-8b91-5a3577af2338
md"""
## Inflation Swap
"""

# ╔═╡ 2077ceec-2fcb-4c7e-969f-4e2ff9911e9c
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/InflSwap_Chart.svg",:width => 400)

# ╔═╡ 30e2787d-d1f3-4952-a9ce-534dd51e0f8a
md"""
##
"""

# ╔═╡ e2c6fd53-4fe8-4f1f-81a1-e4008c056b3d
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/InflSwap1Yr_Des.png",:width => 900)

# ╔═╡ 67bfd8f9-5874-4205-aa6e-9851d967d939
md"""
##
"""

# ╔═╡ 14996238-3aac-4601-a529-e85e182ab028
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/InflSwap1Yr_PxQuotes.png",:width => 900)

# ╔═╡ 928af98c-90a3-4bce-826d-ff7e96d9c3a8
md"""
##
"""

# ╔═╡ e5a9bd4f-cbe9-44ad-bc29-55d767867fe1
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/InflSwap1Yr_Graph.png",:width => 900)

# ╔═╡ 2e7bd373-6edc-44a6-8a8f-b46f88277e03
md"""
## Inflation Swap Cash Flows
"""

# ╔═╡ 727e1c36-6ce2-4114-9831-e7b3981e4ce1
md"""
- The swap is executed between two counterparties at time $t=0$ and has only one cash flow that occurs at maturity in $T$ years.
  - For example, imagine that at time $t=0$, the five-year zero-coupon inflation swap rate is 200 basis points and that the inflation swap has a notional of \$1. 
  - There are no cash flows at time $t=0$ when the swap is executed. 
  - At the maturity of the swap in $T=5$ years, suppose that realized inflation is $I_T$, then the counterparties to the inflation swap exchange a cash flow of 

$$\left[ (1 + 0.0200)^5 -1 \right] − \left[I_T -1 \right],$$

- Thus, if the realized inflation rate was 1.50% per year over the five-year horizon of the swap, 

$$I_T = 1.015^5 = 1.077284$$ 

- In this case, the net cash flow per \$1 notional of the swap from the swap would be 


$$\left[ (1 + 0.0200)^5 -1\right] − \left[1.077284 -1 \right]= 0.026797$$ 
"""

# ╔═╡ 6c9e2711-8153-4ebe-b130-c819ff266ff6
md"""
##
"""

# ╔═╡ e33907ec-bcc1-48c0-a09f-cd746b46d3ea
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/InflationSwap_TermSheet.svg",:width => 900)

# ╔═╡ c0563fe7-6d8d-4a2d-9e47-fe16dcfaed61
md"""
## Example
"""

# ╔═╡ d3fb968d-3aa3-44e0-ba8b-13ba61cc6a5b
md"""
- Notional $N$ [$]: $(@bind Nswap Slider(100:100:1000, default=100, show_value=true))
- Inflation Swap Rate $f$ [%]: $(@bind fswap Slider(0:0.25:10, default=3, show_value=true))
- Time to Maturity $T$ [years]: $(@bind Tswap Slider(1:1:30, default=5, show_value=true))
- Annual Inflation Rate $I$ [%]: $(@bind Iswap Slider(0:0.25:10, default=2, show_value=true))
"""

# ╔═╡ 917d6d5e-bc3d-4f24-b51b-e86533e682ab
Markdown.parse("
- Cash flow on the fixed leg of the inflation swap:

\$N \\times \\left[ (1+f)^T - 1 \\right] = $(Nswap) \\times \\left[ (1+ $(fswap/100))^{$(Tswap)} -1 \\right]= $(Nswap*( (1+fswap/100)^Tswap -1))\$
	
- Cash flow on the floating leg of the swap:
	
\$N \\times \\left[ (1+I)^T - 1 \\right]]= $(Nswap) \\times \\left[ (1+$(Iswap/100))^{$(Tswap)} - 1 \\right]=$(Nswap*((1+Iswap/100)^Tswap-1))\$
	
- Net cash flow of inflation buyer: $(Nswap*(1+Iswap/100)^Tswap - Nswap*(1+fswap/100)^Tswap)
")


# ╔═╡ 921402f8-a70c-4b45-b134-7fd70f0c699a
md"""
# Combining TIPS and Inflation Swap

- Suppose we invest in a TIPS with 6 months to maturity, coupon rate of 4%, and  (inflation-adjusted) principal of $100 .
- Thus, we receive one final cash flow consisting of
  - Inflation-adjusted principal: $$100\times I_{0.5}$$  
    - For simplicity, we ignore the deflation option for now.
  - Inflation-adjusted coupon cash flow: $(c/2) \times I_{0.5} \times 100 = 0.02 \times I_{0.5} \times 100$
- The total cash flow from the TIPS is:
$$\left[100 \times I_{0.5}\right] + \left[2 \times I_{0.5}\right] = 102 \times I_{0.5}$$
"""

# ╔═╡ b9c01bbc-1563-4a58-b2ff-1d70f5f10c43
md"""
- Next, suppose we enter into an inflation swap with notional amount of $102 as inflation seller. Let the fixed rate on the inflation swap be 0.9828%, i.e. $$f=0.009828$$.
- The net cash flow on the inflation swap is
$$102 \times [(1+f)^{0.5}-1] - 102 \times [I_{0.5}-1]$$
- The total cash flow of the TIPS and the inflation swap is:
$$102 \times I_{0.5} + \left(102 \times [(1+f)^{0.5}-1] - 102 \times [I_{0.5}-1] \right)$$
"""

# ╔═╡ faaaae87-46e9-4fbd-82e0-6ac979f332ee
md"""
##
- Simplifying
$$102 \times (1+f)^{0.5} = 102 \times (1+0.9828\%)^{0.5} = 102.50$$
- This is a deterministic cash flow that does not depend on future inflation.

"""

# ╔═╡ 01a5c636-23fb-4e6f-aca5-9bdab11fa66a
md"""
- Suppose the market price of the TIPS is 100, and that the market price of a Treasury note with six months to maturity and coupon rate of 5% is 102.
"""

# ╔═╡ 3e23d630-4e11-4a52-8748-d66b02d1bfd4
md"""
- Next, we take a short position in the Treasury note and buy the TIPS. 
- We pay $100 for the TIPS and get $102 in cash from shorting the Treasury note.
- Our net cash flow is 102 - 100 = 2.
"""

# ╔═╡ 7275809f-4e12-44aa-b7e1-ec9a2b33f870
md"""
- What is our obligation to pay in six months?
  - First, we need to close out the short in the Treasury note and pay $102.50. Thus, we have a cash outflow of -102.50.
  - Second, we have a cash flow from the long TIPS position and the inflation swap of $102.5. This is a cash inflow of 102.50.
  - Our net cash flow is -102.5 + 102.5 = 0. Thus, we have zero cash flow in six months.
- However, we pocketed $2 upfront. 
- This is an arbitrage since we collect $2 now and have no future obligation in six months.
- This is the TIPS-Treasury arbitrage trading strategy in simplified form.
"""

# ╔═╡ c24ef65a-7dde-4f06-bfd0-c15e2f769822
md"""
# Combining TIPS, STRIPS and Inflation Swap

- Suppose we invest in a TIPS with 6 months to maturity, coupon rate of 4%, and  (inflation-adjusted) principal of $100 .
- Thus, we receive one final cash flow consisting of
  - Inflation-adjusted principal: $$100\times I_{0.5}$$  
    - For simplicity, we ignore the deflation option for now.
  - Inflation-adjusted coupon cash flow: $(c/2) \times I_{0.5} \times 100 = 0.02 \times I_{0.5} \times 100$
$$\left[100 \times I_{0.5}\right] + \left[2 \times I_{0.5}\right] = 102 \times I_{0.5}$$
"""

# ╔═╡ 361360cb-bdf4-4f99-8ccc-3fee22847dd2
md"""
- Next, suppose we enter into an inflation swap with notional amount of $102 as inflation seller. Let the fixed rate on the inflation swap be 0.9828%, i.e. $$f=0.009828$$.
- The net cash flow on the inflation swap is
$$102 \times [(1+f)^{0.5}-1] - 102 \times [I_{0.5}-1]$$
- The total cash flow of the TIPS and the inflation swap is:
$$102 \times I_{0.5} + \left(102 \times [(1+f)^{0.5}-1] - 102 \times [I_{0.5}-1] \right)$$
"""

# ╔═╡ 5fea7742-70a3-4a8e-892d-c70a953b0fcf
md"""
##
"""

# ╔═╡ 23e7092b-6006-4ddd-97ff-454128a88e31
md"""
- Simplifying
$$102 \times (1+f)^{0.5} = 102 \times (1+0.9828\%)^{0.5} = 102.50$$
- This is a deterministic cash flow that does not depend on future inflation.
"""

# ╔═╡ 56d6b975-f6d4-447b-a67b-02954f75286e
md"""
- Suppose the market price of the TIPS is 100, and that the market price of a Treasury note with six months to maturity and coupon rate of __6%__ is 102.
"""

# ╔═╡ 9ee52d27-ec6b-4e0d-9696-48e9dd88c7ce
md"""
- Next, we take a short position in the Treasury note and buy the TIPS. 
- We pay $100 for the TIPS and get $102 in cash from shorting the Treasury note.
- Our net cash flow is 102 - 100 = 2.
"""

# ╔═╡ 1771917d-3f40-495d-ad52-50bf674ff0b6
md"""
##
"""

# ╔═╡ 76d70fe8-358f-4f2f-9a00-69a147935282
md"""
- What is our obligation to pay in six months?
- First, we need to close out the short in the Treasury note and pay $103. Thus, we have a cash outflow of -103.00.
- Second, we have a cash flow from the long TIPS position and the inflation swap of $102.5. This is a cash inflow of 102.50.
- Our net cash flow is -103 + 102.5 = -0.50. 
"""

# ╔═╡ c27b5057-3d36-4a80-94f3-d8421874d3b8
md"""
- Thus, we have non-zero cash outflow of fifty cents in six months.
- We want to have zero cash flows in six months. How can we achive this?
- Recall that there are STRIPS which are zero coupon bonds with just one cash flow at maturity.
- All we need is an inflow of fifty cents from a 6-month STRIPS.
"""

# ╔═╡ 06b01ce1-94dd-4ddd-ad17-2bdf3aa950ed
md"""
##
"""

# ╔═╡ 2423e58f-2ff0-4c80-9666-ccb45243ae19
md"""
- Suppose the price of a 6-month Treasury STRIPS is 99.50 (per 100 par value). The STRIPS will give us a cash inflow of 100 in 6 months.
- Since we need \$0.50, we buy \$0.50 par value of this STRIPS.
- This costs us 0.50/100 * 99.50 = $0.4975.
"""

# ╔═╡ a0bf1aaa-edfb-409f-a2ec-eccc00e9b95f
md"""
- Thus, our cash flow today is now the cash inflow of 2 (from the long TIPS and short Treasury note) and the cash outflow of 0.4975 from the STRIPS.
- This is a net cash flow today of 2 - 0.4975 = 1.5025.
- We now have zero cash flow in six months and a positive cash flow of 1.5025 today.
- This is an arbitrage since we collect $1.5025 now and have no future obligation in six months.
"""

# ╔═╡ 201a91a8-4154-414e-86b1-ca578fa105c2
md"""
# TIPS-Treasury Mispricing on December 30, 2008
"""

# ╔═╡ 27038fd7-4dc4-4dd5-87dd-0032478d0622
md"""
- The next table uses real market data on 12/30/2008 and shows the cash flows associated with 
  - the 7.625% Treasury bond with maturity date January 15, 2025, and 
  - the cash flows from the replicating strategy using the 2.375% TIPS issue with the same maturity date that replicates the cash flows of the Treasury bond. 
- Note: 
  - Cash flows are in dollars per $100 notional. 
  - The $I_t$ denotes the realized percentage change in the CPI index from the inception of the strategy to the cash flow date. 
  - Date refers to the number of the semiannual period in which the corresponding cash flows are paid.
"""

# ╔═╡ 14e6f7ed-2a81-4101-a1b5-af627df7c805
md"""
## Cash Flow Table
"""

# ╔═╡ 7c923c8c-9067-42af-b103-391c05bbeb98
Foldable("Cash Flow Table", 
md"""
| Date | Treasury  | TIPS         | Inflation Swaps        | STRIPS   | Total    |
|------|-----------|--------------|------------------------|----------|----------|
| 0    | −169.4793 | -101.2249    | 0                      | -45.6367 | -146.379 |
| 1    | 3.8125    | 1.1875 I$_1$    | 1.1856 − 1.1875 I$_{1}$     | 2.6269   | 3.8125   |
| 2    | 3.8125    | 1.1875 I$_2$    | 1.1638 − 1.1875 I$_{2}$     | 2.6487   | 3.8125   |
| 3    | 3.8125    | 1.1875 I$_3$    | 1.1480 − 1.1875 I$_{3}$     | 2.6645   | 3.8125   |
| 4    | 3.8125    | 1.1875 I$_4$    | 1.1467 − 1.1875 I$_{4}$     | 2.6658   | 3.8125   |
| 5    | 3.8125    | 1.1875 I$_5$    | 1.1307 − 1.1875 I$_{5}$     | 2.6818   | 3.8125   |
| 6    | 3.8125    | 1.1875 I$_6$    | 1.1376 − 1.1875 I$_{6}$     | 2.6749   | 3.8125   |
| 7    | 3.8125    | 1.1875 I$_7$    | 1.1566 − 1.1875 I$_{7}$     | 2.6559   | 3.8125   |
| 8    | 3.8125    | 1.1875 I$_8$    | 1.1616 − 1.1875 I$_{8}$     | 2.6509   | 3.8125   |
| 9    | 3.8125    | 1.1875 I$_9$    | 1.1630 − 1.1875 I$_{9}$     | 2.6495   | 3.8125   |
| 10   | 3.8125    | 1.1875 I$_{10}$   | 1.1773 − 1.1875 I$_{10}$    | 2.6352   | 3.8125   |
| 11   | 3.8125    | 1.1875 I$_{11}$   | 1.1967 − 1.1875 I$_{11}$    | 2.6128   | 3.8125   |
| 12   | 3.8125    | 1.1875 I$_{12}$   | 1.2095 − 1.1875 I$_{12}$    | 2.6030   | 3.8125   |
| 13   | 3.8125    | 1.1875 I$_{13}$   | 1.2248 − 1.1875 I$_{13}$    | 2.5877   | 3.8125   |
| 14   | 3.8125    | 1.1875 I$_{14}$   | 1.2466 − 1.1875 I$_{14}$    | 2.5659   | 3.8125   |
| 15   | 3.8125    | 1.1875 I$_{15}$   | 1.2683 − 1.1875 I$_{15}$    | 2.5442   | 3.8125   |
| 16   | 3.8125    | 1.1875 I$_{16}$   | 1.2866 − 1.1875 I$_{16}$    | 2.5259   | 3.8125   |
| 17   | 3.8125    | 1.1875 I$_{17}$   | 1.3058 − 1.1875 I$_{17}$    | 2.5067   | 3.8125   |
| 18   | 3.8125    | 1.1875 I$_{18}$   | 1.3304 − 1.1875 I$_{18}$    | 2.4821   | 3.8125   |
| 19   | 3.8125    | 1.1875 I$_{19}$   | 1.3556 − 1.1875 I$_{19}$    | 2.4569   | 3.8125   |
| 20   | 3.8125    | 1.1875 I$_{20}$   | 1.3792 − 1.1875 I$_{20}$    | 2.4333   | 3.8125   |
| 21   | 3.8125    | 1.1875 I$_{21}$   | 1.4009 − 1.1875 I$_{21}$    | 2.4116   | 3.8125   |
| 22   | 3.8125    | 1.1875 I$_{22}$   | 1.4225 − 1.1875 I$_{22}$    | 2.3900   | 3.8125   |
| 23   | 3.8125    | 1.1875 I$_{23}$   | 1.4427 − 1.1875 I$_{23}$    | 2.3698   | 3.8125   |
| 24   | 3.8125    | 1.1875 I$_{24}$   | 1.4635 − 1.1875 I$_{24}$    | 2.3490   | 3.8125   |
| 25   | 3.8125    | 1.1875 I$_{25}$   | 1.4806 − 1.1875 I$_{25}$    | 2.3319   | 3.8125   |
| 26   | 3.8125    | 1.1875 I$_{26}$   | 1.4979 − 1.1875 I$_{26}$    | 2.3146   | 3.8125   |
| 27   | 3.8125    | 1.1875 I$_{27}$   | 1.5126 − 1.1875 I$_{27}$    | 2.2999   | 3.8125   |
| 28   | 3.8125    | 1.1875 I$_{28}$   | 1.5277 − 1.1875 I$_{28}$    | 2.2848   | 3.8125   |
| 29   | 3.8125    | 1.1875 I$_{29}$   | 1.5407 − 1.1875 I$_{29}$    | 2.2718   | 3.8125   |
| 30   | 3.8125    | 1.1875 I$_{30}$   | 1.5548 − 1.1875 I$_{30}$    | 2.2577   | 3.8125   |
| 31   | 3.8125    | 1.1875 I$_{31}$   | 1.5676 − 1.1875 I$_{31}$    | 2.2449   | 3.8125   |
| 32   | 3.8125    | 1.1875 I$_{32}$   | 1.5823 − 1.1875 I$_{32}$    | 2.2302   | 3.8125   |
| 33   | 103.8125  | 101.1875 I$_{33}$ | 135.9861 −101.1875 I$_{33}$ | -32.1736 | 103.8125 |
""")

# ╔═╡ 004efec5-23d3-4940-abff-9024820daf65
md"""
- The table shows the actual cash flows that would result from applying the arbitrage strategy on December 30, 2008, to replicate the 7.625% coupon Treasury bond maturing on February 15, 2025. 
- As shown, the price of the Treasury bond is **$169.479.** 
"""

# ╔═╡ ac297a30-ce58-4c07-b72f-df4a149dc565
md"""
- To replicate the Treasury bond’s cash flows, the arbitrageur buys a 2.375% coupon TIPS issue with the same maturity date for a price of $101.225. 
"""

# ╔═╡ 8eaece30-202e-4e8b-a16b-adb3375f008c
md"""
- Since there are 33 semiannual coupon payment dates, 33 inflation swaps are executed with the indicated notional amounts.
- Finally, positions in Treasury STRIPS of varying small notional amounts are also taken by the arbitrageur. 
"""

# ╔═╡ b729c130-5813-4eab-92a1-673a8d29a897
md"""
- The net cash flows from the replicating strategy exactly match those from the Treasury bond, but at a cost of only **$146.379.**
- Thus, the cash flows from the Treasury bond can be replicated at a cost that is **\$23.10** less than that of the Treasury bond.
"""

# ╔═╡ cded3cca-c9ac-4d7d-b9dd-4c5497aa955e
md"""
# Case Study
- Date: October 5, 2006
- TIPS CUSIP: 912828EA
- Treasury Note CUSIP: 912828EE
"""

# ╔═╡ d4dab771-87f1-4fa2-b6a2-900a51af4586
md"""
## TIPS: 912828EA
"""

# ╔═╡ 8f3a465e-af54-4b0e-9210-87c140629f2f
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/TIPS_912828EA_Des.png",:width => 800)

# ╔═╡ d61da00e-9d8c-43e8-89c5-e70220dc761a
md"""
##
"""

# ╔═╡ 049debc7-b1d5-4908-9b27-70344995a4c4
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/TIPS_912828EA_PxGraph.png",:width => 800)

# ╔═╡ abda6c84-f124-4d61-bb40-0517e28fbcf6
md"""
##
"""

# ╔═╡ 72721c2c-f227-469a-91d9-dbec158c2fa7
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/TIPS_912828EA_PxQuotes.png",:width => 800)

# ╔═╡ 312e0229-445e-42d4-8a0d-709c590c1add
md"""
## Treasury Note: 912828EA
"""

# ╔═╡ 97d9ba4b-880f-464e-bd94-7b72a86094b7
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/Treasury_912828EE_Des.png",:width => 800)

# ╔═╡ bf6e7d0a-7e33-47b1-9240-a0af661057f5
md"""
##
"""

# ╔═╡ d16e82d8-faa9-444f-8db7-6f442c5e5fd4
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/Treasury_912828EE_PxQuotes.png",:width => 800)

# ╔═╡ dc265679-85cd-4ff1-a728-6353f36e3a9c
md"""
##
"""

# ╔═╡ e36dc8d3-3b4e-46c4-9259-007f75068591
Resource("https://raw.githubusercontent.com/fleckenstein-m/TIPS_Treas_W2022/main/notebooks/Assets/Treasury_912828EE_PxGraph_2.png",:width => 800)

# ╔═╡ 4ac1725a-d9e5-4587-9b03-ae8b7379ed56
md"""
## Inflation Swap Rates
- Date:	10/5/2006	

| Tenor	  | SwapRate| Bloomberg| Ticker      | 
|-------- |---------|--------- | ---------   |
|1 Year	  |	0.01850	| USSWIT1  | CMPN CURNCY | 
|2 Years  |	0.02133	| USSWIT2  | CMPN CURNCY |
|3 Years  | 0.02313	| USSWIT3  | CMPN CURNCY |
|4 Years  |	0.02425	| USSWIT4  | CMPN CURNCY |
|5 Years  |	0.02503	| USSWIT5  | CMPN CURNCY |
|6 Years  |	0.02543	| USSWIT6  | CMPN CURNCY |
|7 Years  |	0.02580	| USSWIT7  | CMPN CURNCY |
|8 Years  |	0.02623	| USSWIT8  | CMPN CURNCY |
|9 Years  |	0.02648	| USSWIT9  | CMPN CURNCY |
|10 Years |	0.02683	| USSWIT10 | CMPN CURNCY |
|12 Years |	0.02733	| USSWIT12 | CMPN CURNCY |
|15 Years |	0.02798	| USSWIT15 | CMPN CURNCY |
|20 Years |	0.02960	| USSWIT20 | CMPN CURNCY |
|25 Years |	0.03070	| USSWIT25 | CMPN CURNCY |
|30 Years |	0.03170	| USSWIT30 | CMPN CURNCY |
"""

# ╔═╡ 00c3ea64-bbe5-4d7a-a1b2-1197b1455bec
md"""
## STRIPS Prices
"""

# ╔═╡ 432dae1b-89b1-4e8a-b59a-98e00391b368
Foldable("Treasury STRIPS Prices", 
md"""
#### STRIPS Prices
- Date:	10/5/2006

| BB ID            | Maturity   | 10/5/2006 |
|------------------|------------|-----------|
| 9128333P3 Govt   | 11/30/2006 | 99.483    |
| 9128333U2   Govt | 2/28/2007  | 98.308    |
| 9128333W8 Govt   | 3/31/2007  | 97.813    |
| 9128333Y4   Govt | 4/30/2007  | 97.414    |
| 9128333Z1 Govt   | 5/31/2007  | 97.103    |
| 9128334E7   Govt | 8/31/2007  | 96.008    |
| 9128334G2 Govt   | 9/30/2007  | 95.626    |
| 912833GB0   Govt | 11/15/2007 | 94.937    |
| 9128334K3 Govt   | 11/30/2007 | 94.885    |
| 912833C57   Govt | 1/15/2008  | 94.324    |
| 9128334R8 Govt   | 1/31/2008  | 94.166    |
| 912833CT5   Govt | 2/15/2008  | 93.973    |
| 9128335C0 Govt   | 2/29/2008  | 93.877    |
| 9128335K2   Govt | 3/31/2008  | 93.265    |
| 9128335Z9 Govt   | 5/31/2008  | 92.808    |
| 912833C65   Govt | 7/15/2008  | 92.106    |
| 9128336P0 Govt   | 7/31/2008  | 91.974    |
| 912833CU2   Govt | 8/15/2008  | 91.959    |
| 9128335D8 Govt   | 8/31/2008  | 91.848    |
| 912833ZY9   Govt | 9/15/2008  | 91.626    |
| 9128335L0 Govt   | 9/30/2008  | 91.243    |
| 9128335T3   Govt | 10/31/2008 | 91.086    |
| 912833GD6 Govt   | 11/15/2008 | 90.914    |
| 9128336A3   Govt | 11/30/2008 | 90.84     |
| 912833CV0 Govt   | 2/15/2009  | 89.985    |
| 9128335E6   Govt | 2/28/2009  | 89.88     |
| 9128332B5 Govt   | 3/15/2009  | 89.773    |
| 9128335M8   Govt | 3/31/2009  | 89.713    |
| 9128335U0 Govt   | 4/30/2009  | 88.682    |
| 912833GE4   Govt | 5/15/2009  | 88.717    |
| 9128336B1 Govt   | 5/31/2009  | 88.869    |
| 9128332J8   Govt | 7/15/2009  | 87.956    |
| 9128336R6 Govt   | 7/31/2009  | 87.681    |
| 9128335F3   Govt | 8/31/2009  | 87.87     |
| 9128333K4 Govt   | 9/15/2009  | 87.666    |
| 9128335N6   Govt | 9/30/2009  | 86.913    |
| 9128335V8 Govt   | 10/31/2009 | 87.278    |
| 912833GF1   Govt | 11/15/2009 | 87.055    |
| 9128336C9 Govt   | 11/30/2009 | 86.911    |
| 9128333S7   Govt | 1/15/2010  | 86.419    |
| 912833CX6 Govt   | 2/15/2010  | 86.161    |
| 9128335G1   Govt | 2/28/2010  | 86.125    |
| 9128333V0 Govt   | 3/15/2010  | 85.948    |
| 9128335P1   Govt | 3/31/2010  | 85.789    |
| 9128336D7 Govt   | 5/31/2010  | 85.119    |
| 9128335H9   Govt | 8/31/2010  | 84.304    |
| 9128334F4 Govt   | 9/15/2010  | 84.145    |
| 9128336E5   Govt | 11/30/2010 | 83.434    |
| 9128334N7 Govt   | 1/15/2011  | 82.742    |
| 9128335J5   Govt | 2/28/2011  | 82.509    |
| 912834BA5 Govt   | 3/15/2011  | 82.311    |
| 9128336F2   Govt | 5/31/2011  | 81.984    |
| 912833DA5 Govt   | 8/15/2011  | 80.721    |
| 9128336W5   Govt | 8/31/2011  | 80.652    |
| 912834BB3 Govt   | 9/15/2011  | 80.541    |
| 9128336Z8   Govt | 11/30/2011 | 80.731    |
| 9128337G9 Govt   | 2/29/2012  | 78.767    |
| 9128337K0   Govt | 5/31/2012  | 78.302    |
| 912833Y53 Govt   | 8/31/2012  | 77.112    |
| 912833Y87   Govt | 11/30/2012 | 76.043    |
| 912833Z78 Govt   | 2/28/2013  | 75.172    |
| 912834AA6   Govt | 5/31/2013  | 74.184    |
| 912834AF5 Govt   | 8/31/2013  | 73.578    |
| 912834AJ7   Govt | 11/30/2013 | 72.472    |
| 912834AV0 Govt   | 2/28/2014  | 71.589    |
| 912834DW5   Govt | 5/31/2014  | 70.67     |
| 912834AW8 Govt   | 8/31/2014  | 69.906    |
| 912834DX3   Govt | 11/30/2014 | 69.049    |
| 912834AX6 Govt   | 2/28/2015  | 68.153    |
| 912834DY1   Govt | 5/31/2015  | 67.41     |
| 912834AY4 Govt   | 8/31/2015  | 66.51     |
| 912834DZ8   Govt | 11/30/2015 | 65.644    |
| 912834AZ1 Govt   | 2/29/2016  | 64.789    |
| 912834EA2   Govt | 5/31/2016  | 64.018    |
| 912834EQ7 Govt   | 8/31/2016  | 63.176    |
| 912834EW4   Govt | 11/30/2016 | 62.346    |
| 912834FC7 Govt   | 2/28/2017  | 61.659    |
""")

# ╔═╡ d1eb23f3-7142-493d-b2e6-d4f844e2bfc6
md"""
## Calculations
"""

# ╔═╡ 398086e4-4a4c-45f6-a32d-cb5d8847233c
md"""
|				             | TIPS			    | Tbond     | 
|----------------------------|------------------|-----------|
| CUSIP			             | 912828EA 		| 912828EE  |
| Maturity		             | 7/15/2015		| 8/15/2015 |  
| Issue Date	             | 7/15/2005		| 8/15/2005 |
| Coupon		             | 1.875%		    | 	4.250%  |
| First Coupon Date	         | 1/15/2006		| 2/15/2006 |
| Second Coupon Date         | 7/15/2006		| 8/15/2006 |
| Reference CPI on issue date| 194.50968		| $-$       |    
| **Price Quote**	             | 96-20		    | 97-15+    |
"""

# ╔═╡ 7c15360a-9f7f-45d0-8059-0420dc46b231
md"""
## Step 1.1: Calculate Full Prices of the Treasury
"""

# ╔═╡ cf85e64a-d5c4-4d04-b6ba-04ac003f7289
Markdown.parse("
- **Treasury 912727EE**
  - Quoted Price: 97-15+ per \$100 notional.
> \$97 + \\frac{15}{32} + \\frac{1}{64} = $(97+15/32+1/64)\$
  - Accrued Interest: 
  - Current Date: 10/05/2006
  - Last Coupon Date: 8/15/2006
  - Next Coupon Date: 2/15/2007
- Days since last coupon = 17 days in August *(daycount includes the date of the previous coupon, i.e. 16+1=17)* + 30 days in September + 4 days October *(daycount excludes the settlement date, thus 4 days)*
> \$17 + 30 + 4 = $(17+30+4)\$
- Days in the coupon period = (31-15) days in August + 30 days September + 31 days in October + 30 days in November + 31 days in December + 31 days in January + 15 days in February
> \$(31-15) + 30 + 31 + 30 + 31 + 31 + 15 = $(31-15+30+31+30+31+31+15)\$
- Calculate accrued interest on October 5, 2006.
> Accrued Interest = \$\\frac{0.0425}{2} \\times 100 \\times \\frac{51}{184} = $((31-15+30+5)/(31-15+30+31+30+31+31+15)*0.0425/2*100)\$
- Calculate the full price of the Treasury note per \$100 notional. 
  - The full price is the quoted price plus accrued interest.
> Full Price = \$$((31-15+30+5)/(31-15+30+31+30+31+31+15)*0.0425/2*100+(97+15/32+1/64))\$
")

# ╔═╡ 31ef4b01-b5ed-47cc-9ff1-6d92ff7bd2b4
md"""
## Step 1.2: Calculate Full Prices of the TIPS
"""

# ╔═╡ d670b261-f427-4498-a8df-fcdacdb14d3e
Markdown.parse("
- **TIPS 912828EA**
  - Quoted Price: 96-20 per \$100 notional.
> \$96 + \\frac{20}{32}=$(96+20/32)\$
  - Accrued Interest:
- Current Date: 10/05/2006
  - Last Coupon Date: 7/15/2006
  - Next Coupon Date: 1/15/2007
- Days since last coupon = 17 days in July *(daycount includes the date of the previous coupon, i.e. 16+1=17)* + 31 days in August + 30 days in September + 4 days October *(daycount excludes the settlement date, thus 4 days)*
> \$17 + 31 + 30 + 4 = $(17+31+30+4)\$
- Days in the coupon period = (31-15) days in July + 31 days in August + 30 days September + 31 days in October + 30 days in November + 31 days in December + 15 days in January 
> \$(31-15) + 31 + 30 + 31 + 30 + 31 + 15 = $(31-15+31+30+31+30+31+15)\$
- Calculate accrued interest on October 5, 2006.
> Accrued Interest = \$\\frac{0.01875}{2} \\times 100 \\times \\frac{82}{184} = $(0.01875/2*100*(82/184))\$
- Calculate the full price of the Treasury TIPS per \$100 notional. 
  - The full price is the quoted price plus accrued interest.
> Full Price = \$$((0.01875/2*100*(82/184))+(96+20/32))\$
")

# ╔═╡ 083a0cb1-a597-46ca-84c0-e5b7ce23b53a
md"""
## Step 2: Set-up Cash Flows of the TIPS, Inflation Swaps and STRIPS
- *Note, initially we assume that the TIPS and Treasury note have identical maturity and coupon cash flow dates. The *Time* column lists the coupon payment dates of the TIPS.
- The (real) coupon cash flows of the TIPS are $\frac{0.01875}{2}\times 100=0.9375$
- The coupon cash flows of the Treasury note are are $\frac{0.0425}{2}\times 100=2.125$
- *Notation*:
  - Let $P_{STR}(t,T)$ be the time-$t$ price of Treasury STRIPS with maturity in $T$ years. In the table below, we omit the $T$ to designate the coupon cash flow dates of the TIPS. 
  - Let $x_T$ denote the notional amount of the Treasury STRIPS.
  - Let $I_t/I_0$ denote the inflation adjustment on the TIPS at time $t$.
  - Let $P_{\textrm{Swap}}(t)$ denote the cash flow on the fixed leg of the inflation swap with notional of \$1, i.e. $$P_{\textrm{Swap}}(t)=(1+f_t)^t-1$$ 
  - The floating leg of the inflation swap has a time-$t$ cash flow of $\frac{I_t}{I_0} - 1$
  
"""

# ╔═╡ 80176747-6460-4840-992f-394e1c1112b2
md"""
## 2.1. Start with TIPS
"""

# ╔═╡ b0b36b4c-9d44-42cf-a1c2-a97fad25b84e
md"""
| Time		| TIPS 			| 
|-----------|---------------|
| 10-05-06	| $-97.0428$	    |
| 1/15/2007 | $0.9375 \times \frac{I_t}{I_0}$ |  
|  $\vdots$ | $\vdots$      | 
| 7/15/2015 | $(0.9375+100) \times \frac{I_T}{I_0}$ | 
"""

# ╔═╡ 903a6516-2919-4078-89cc-264a726e07ca
md"""
## 2.2. Add Inflation Swaps
- The notional amount of the inflation swap is equal to the real coupon cash flow of the TIPS 
  - In this example, $N=0.9375$.
"""

# ╔═╡ 14623ccd-d970-4046-8e1c-89d1652e3bcf
md"""
| Time		| TIPS 			| Inflation Swaps | 
|-----------|---------------|-----------------|
| 10-05-06	| $-97.0428$	    | 0               |
| 1/15/2007 | $0.9375 \times \frac{I_t}{I_0}$ |  $-0.9375 \times \left(\frac{I_t}{I_0}-1\right) + 0.9375 \times P_{\textrm{Swap}}(t)$  | 
| $\vdots$	| $\vdots$	    | $\vdots$        |
| 7/15/2015 | $(0.9375+100) \times \frac{I_T}{I_0}$ | $-(0.9375+100) \times \left( \frac{I_T}{I_0} -1\right) + (0.9375+100) \times P_{\textrm{Swap}}(T)$ |
"""

# ╔═╡ 932c04a6-64e3-4d73-a083-c836fbafdbb3
md"""
## 2.3. Net TIPS and Inflation Swaps Cash Flows
"""

# ╔═╡ fb2d12f6-ebd2-4be5-9506-cdaa52cfaa1e
md"""
| Time		| TIPS 	+ Inflation Swaps | 
|-----------|-------------------------|
| 10-05-06	| $-97.0428$	              |
| 1/15/2007 | $0.9375  + 0.9375 \times P_{\textrm{Swap}}(t)$  | 
| $\vdots$	| $\vdots$              |
| 7/15/2015 | $(0.9375+100) + (0.9375+100) \times P_{\textrm{Swap}}(T)$ |
"""

# ╔═╡ 8d63c259-14d0-45db-bd85-93b71e963dbb
md"""
## 2.4. Add Treasury STRIPS
"""

# ╔═╡ 92383772-0e20-4302-89ca-ccb914a05a33
md"""
| Time		| TIPS + Inflation Swaps | STRIPS 		   |
|-----------|------------------------|-----------------|
| 10-05-06	| $-97.0428$	             |$-\sum_{T_i} P_{\textrm{STR}}(0,T_i)$	|
| 1/15/2007 | $0.9375 + 0.9375 \times P_{\textrm{Swap}}(t)$  | $x_t \times 100$ | 
| $\vdots$  | $\vdots$               | $\vdots$        | 
| 7/15/2015 | $(0.9375+100) + (0.9375+100) \times P_{\textrm{Swap}}(T)$ | $x_T \times 100$ |
"""

# ╔═╡ d7e38a5e-2c88-4728-b1cc-d98a5e1a6ec1
md"""
## 2.5. Add Treasury Note
"""

# ╔═╡ 50e13665-bf79-4931-b545-0050a933e2fa
md"""
| Time		| TIPS + Inflation Swaps | STRIPS 		| Treasury Note 	|
|-----------|------------------------|------------- |-------------------|
| 10-05-06	| $-97.0428$	             | $-\sum_{T_i} P_{\textrm{STR}}(0,T_i)$	| $-98.07337$          | 
| 1/15/2007 | $0.9375 \times (1+ P_{\textrm{Swap}}(t))$  | $x_t \times 100$ | $2.125$ |
| $\vdots$	| $\vdots$             | $\vdots$	| $\vdots$        | 
| 7/15/2015 | $100.9375 \times (1+P_{\textrm{Swap}}(T))$ | $x_T \times 100$ | $102.125$ |
"""

# ╔═╡ 03f0f3c5-cd48-4dec-b379-0d4245235f25
md"""
## 2.6. Calculate the STRIPS Positions
"""

# ╔═╡ 0e8e476f-9933-4fd0-9ad6-b01f7918a67b
md"""
- Next, we calculate the positions in Treasury STRIPS to match the cash flows from the Treasury note exactly.
- For each coupon date $t$
  - Set the notional of the Treasury STRIPS to enter into such that the total cash flow from the TIPS, inflation swap, and STRIPS matches exactly the fixed coupon cash flow of the Treasury note.
  - To keep the notation general, let the fixed real TIPS cash flow be denoted by $c_{\textrm{TIPS}}= 0.9375$ and let the Treasury note cash flow be $c_{\textrm{Tnote}}=2.125$.
${c_{\textrm{TIPS}}} \times (1 + {P_{\textrm{Swap}}(t)}) + x_t \cdot 100 = {c_{\textrm{Tnote}}}$
$\to {x_t} = \frac{{{c_{\textrm{Tnote}}} - {c_{\textrm{TIPS}}} ( 1+ \cdot {P_{\textrm{Swap}}(t)}})}{{100}}$
$\to {x_t} = \frac{{{2.125} - ({c_{\textrm{TIPS}}} + {c_{\textrm{TIPS}}} \cdot {P_{\textrm{Swap}}(t)}})}{{100}}$


- For the maturity date $T$
  - Set the notional of the Treasury STRIPS to enter into such that the total cash flow from the TIPS, inflation swap, and STRIPS matches exactly the fixed coupon and principal cash flow of the Treasury note.
$\left( {100 + {c_{\textrm{TIPS}}}} \right) \times (1+ {P_{\textrm{Swap}}(T)}) + x \cdot 100 = 100 + {c_{\textrm{Tnote}}}$
$\to {x_T} = \frac{({100+{c_{Tnote}}) - (100+{c_{\textrm{TIPS}}}) \times (1 +{P_{\textrm{Swap}}(T)})}}{{100}}$
"""

# ╔═╡ 5ec83302-d399-49a5-86fe-514f30d76c7b
md"""
## Using Market Data
"""

# ╔═╡ 9860adbf-82c4-4961-a0e4-dd5c51037430
md"""
## 2.3. Net TIPS and Inflation Swaps Cash Flows
"""

# ╔═╡ 68cdb801-d6ca-4fe1-8510-5d66ac78e95e
begin
	cfDates2=Dates.Date.(["01/15/2007","07/15/2007","01/15/2008","07/15/2008","01/15/2009","07/15/2009","01/15/2010","07/15/2010","01/15/2011","07/15/2011","01/15/2012","07/15/2012","01/15/2013","07/15/2013","01/15/2014","07/15/2014","01/15/2015","07/15/2015"],"mm/dd/yyyy")
cfSwaps=[0.014123,0.017091,0.019628,0.020925,0.021960,0.022847,0.023544,0.024078,0.024534,0.024914,0.025180,0.025364,0.025533,0.025768,0.025953,0.026201,0.026308,0.026458]
cfTenors=[0.279500,0.775300,1.279500,1.778100,2.282200,2.778100,3.282200,3.778100,4.282200,4.778100,5.282200,5.780800,6.284900,6.780800,7.284900,7.780800,8.284900,8.780800]
df2 = DataFrame(Date=cfDates2, InflationSwapRates=cfSwaps,SwapTenors=cfTenors)
end

# ╔═╡ 9b1b0269-d975-446a-a168-3db32d0fdb95
md"""
- The column *Inflation Swap Rates* shows the inflation swap rates from the Bloomberg system on 10/5/2006.
  - _Note: To get inflation swap rates with tenors exactly matching the cash flow dates of the TIPS, we make two adjustments. First, we need to account for seasonalities in inflation swap rates (e.g. inflation rates for certain months during the year are higher/lower than in other months). Second, swap rates for short tenors (e.g. 1 month) are known because the reference CPI index values for near-term months are already known in the current month due to the 3-month indexaction lag). For details, see Fleckenstein, Longstaff, and Lustig (2014)._
- The column SwapTenors shows the swap tenors as a fraction of a year.
  - The cash flow dates of the inflation swaps are on the coupon cash flow dates of the TIPS.
  - For example, the first tenor as a fraction of a year is 0.2795.
    - (31-5) days in October + 30 days in November + 31 days in December + 15 days in January = 102. Thus, 102/365=0.2795. Similarly for the other cash flow dates.
"""

# ╔═╡ 59bdffc6-b6fd-45f7-98dc-aec5aab8b9a7
Markdown.parse("
## Calculate Cash Flows on the Fixed-Leg of the Inflation Swap
- We calculate the cash flows on the fixed leg of the inflation swap from the inflation swap rates.
- Recall that the fixed leg of the inflation swap has cash flows \$(1+f)^T\$ where \$f\$ is the inflation swap rate and \$T\$ is the swap tenor.
- Swap Fixed Leg = \$\\left( 1 + f(T)\\right)^{T} -1\$
  - For example, for the swap expiring on 2008-01-15, we have 
\$(1+0.019628)^{1.2795}-1 = $((1+0.019628)^1.2795-1)\$
")

# ╔═╡ 4ca9e7a6-fa37-4df5-8941-4aa65af2822f
begin
	df3 = copy(df2)
	df3.SwapFixedLeg = ((1 .+ df2.InflationSwapRates).^(df2.SwapTenors) .-1)
	df3
end

# ╔═╡ 9b5dafa0-1ea6-482f-98a8-f2b8bfb7e9f0
begin
	df4 = copy(df3)
	df4.TIPSAndInflationSwap = (0.01875/2*100).* (1 .+ df4.SwapFixedLeg)
	df4.TIPSAndInflationSwap[end] = (100 + (0.01875/2*100)) .* (1+df4.SwapFixedLeg[end])  
	df4
end

# ╔═╡ a89a9f56-8c94-47e0-9588-48ce9dcd97a4
md"""
## 2.4. Add Treasury STRIPS
"""

# ╔═╡ 81506749-c1b6-4dac-beeb-d551698afb34
begin
	df5 = copy(df4)
	select!(df5,:Date,:TIPSAndInflationSwap)
	df5.STRIPS = NaN.*ones(length(df5.Date))
	#df5.STRIPS = [98.6650,96.3040,94.1340,92.0890,90.1020,88.1370,86.2470,84.4300,82.6180,80.9500,78.6780,76.8630,75.0760,73.3200,71.5890,69.9060,68.1530,66.5100]
	df5
end

# ╔═╡ 77b7030e-0cad-4d86-a70e-7896e0e45da7
md"""
## 2.5. Add Treasury Note
"""

# ╔═╡ b00301af-7ee3-4266-9878-44616cba7ecd
begin
	df6 = copy(df5)
	df6.TNote = 2.125*ones(length(df6.Date))
	df6.TNote[end] = df6.TNote[end]+100
	df6
end

# ╔═╡ 9c8fe1c2-b148-4ded-b5ae-d9c512479a50
md"""
## 2.6. Calculate the STRIPS Positions
"""

# ╔═╡ 932d7811-ebb5-4807-8270-afc8905e7b58
begin
	df6.STRIPS = df6.TNote .- df6.TIPSAndInflationSwap
	df6
end

# ╔═╡ 95c3bcc9-e52f-475e-895b-c8db7f297b8c
begin
	df7 = copy(df6)
	df7.TIPSInflationSwapSTRIPS = df7.TIPSAndInflationSwap .+ df7.STRIPS
	select!(df7,:Date,:TIPSInflationSwapSTRIPS,:TNote)
end

# ╔═╡ 3115e3a5-886e-4315-9c05-36cf9fe7692e
md"""
## 2.7. Calculate the Market Price fo the STRIPS Positions
"""

# ╔═╡ 89d87124-23a2-4241-ad68-73b5be83106b
begin
	df8 = copy(df7)
	select!(df8,:Date,)
	df8.STRIPS = [98.6650,96.3040,94.1340,92.0890,90.1020,88.1370,86.2470,84.4300,82.6180,80.9500,78.6780,76.8630,75.0760,73.3200,71.5890,69.9060,68.1530,66.5100]
	df8
end

# ╔═╡ 73acdb08-b4d2-4e29-8004-1a936e72982f
md"""
- The column STRIPS shows the market prices of Treasury STRIPS from the Bloomberg system on 10/5/2006.
  - _Note: To match exactly the dates of the TIPS coupon cash flows, we interpolate market prices of the Treasury STRIPS. For details, see Fleckenstein, Longstaff, and Lustig (2014)._
"""

# ╔═╡ 2c8ba6e2-83a9-4c4d-98a5-a1325fba7736
begin
	df9 = copy(df7)
	df9.STRIPSPrices = df6.STRIPS .* df8.STRIPS./100
	df9
end

# ╔═╡ 5aa2939e-d286-49f8-9601-3ec5fad21a4c
begin
	PxSTRIPS = sum(df9.STRIPSPrices)
	display("")
end

# ╔═╡ 138a92e6-98bc-49d9-8ac1-2d75f41daaeb
md"""
- Thus, the total price of entering the STRIPS positionss is $PxSTRIPS
"""

# ╔═╡ 26534a5e-a19b-4ef3-b4b3-1ab10700c601
md"""
## Summary
- To summarize
  - The TIPS has a market price of $97.0428. 
  - A long position in the TIPS, inflation swaps and STRIPS costs \$97.0428 - \$1.1887 = \$95.8541.
  - The Treasury note has a market price of 98.0734.
  - This is a puzzle because the price of two securities with exactly the same cash flows are different. The Treasury note is \$2.22 more expensive than its equivalent TIPS.
  - Thus, by buying the TIPS and entering into the inflation swaps and STRIPS and by taking a short we have an arbitrage.
"""

# ╔═╡ 569d7b82-ee46-42e2-b24e-e22272769452
md"""
## Details
- Note that the TIPS and the Treasury have slightly different maturity dates.
  - The TIPS has maturity date on July 15, 2015.
  - The Treasury note has maturity date on August 15, 2015.
- To adjust for this small difference, we take the following approach.
  - Step 1: We calculate the yield to maturity of the TIPS.
  - Step 2: We calculate the price of the Treasury note by discounting the Treasury note cash flows by the yield computed in the previous step.
- The price calculated in step 2 is the price of the TIPS that can be compared to the price of the Treasury note because it accounts for the difference in th timing of cash flows.
- The yield of the TIPS turns out to be 4.97% and the market price of the Treasury note if its yield is 4.97% turns out to be 95.4583.
- Thus the Treasury note is \$98.07337 - \$95.4583 = \$2.61507 more expensive than the equivalent TIPS and the arbitrage mispricing is 2.61507.
"""

# ╔═╡ 53c77ef1-899d-47c8-8a30-ea38380d1614
md"""
## Wrap-Up
"""

# ╔═╡ 670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
begin
	html"""
	<fieldset>      
        <legend>Outline</legend>      
		<br>    
		<input type="checkbox" value="" checked>TIPS-Treasury Trading Strategy<br><br>
		<input type="checkbox" value="" checked>Treasury TIPS<br><br>
		<input type="checkbox" value="" checked>Inflation Swaps<br><br>
	    <input type="checkbox" value="" checked>The U.S. Treasury Bond Puzzle<br><br>
	</fieldset>      
	"""
end

# ╔═╡ 011994b7-8b69-49ee-a370-d09600310323
md"""
##
"""

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
## Reading: 
Fleckenstein, Matthias, Francis A. Longstaff, and Hanno Lustig, 2014, The TIPS–Treasury Bond Puzzle, Journal of Finance, Volume 69, Issue 5, 2014, 2151–2197.

"""

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
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.2.2"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.22.4"
PlutoUI = "~0.7.15"
ShortCodes = "~0.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

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

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

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
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

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
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

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
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

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
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

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
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

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
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

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

[[Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

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
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

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
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

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
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "6841db754bd01a91d281370d9a0f8787e220ae08"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.4"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "633f8a37c47982bff23461db0076a33787b17ecd"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.15"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "69fd065725ee69950f3f58eceb6d144ce32d627d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.2"

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
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "244586bc07462d22aed0113af9c731f2a518c93e"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.10"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[ShortCodes]]
deps = ["Base64", "CodecZlib", "HTTP", "JSON3", "Memoize", "UUIDs"]
git-tree-sha1 = "866962b3cc79ad3fee73f67408c649498bad1ac0"
uuid = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
version = "0.3.2"

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
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

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
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

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

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

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
# ╟─41d7b190-2a14-11ec-2469-7977eac40f12
# ╟─f0545c67-5cfd-438f-a9ef-92c35ebaefa4
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─d2908a7c-51af-431c-ac09-4a7d89dbf02f
# ╟─886da2d4-c1ec-4bb4-8733-e3b46c95dd36
# ╟─6334202e-2047-4e7c-beca-020768340f08
# ╟─98f202ba-7720-40fd-b618-87bd30de840c
# ╟─410b6e69-0ebc-4e2f-9b07-48b7f112ab83
# ╟─8f8c2c95-25ef-4da0-afe1-b0a204911aeb
# ╟─70e71241-e939-4b06-bcbe-ff7cf611df7a
# ╟─3e8baccf-799d-4694-99b0-9612bc59928f
# ╟─355989df-4aab-4c82-9e43-67123e9aecee
# ╟─9185f93e-3503-4dff-8133-8afd36fe148b
# ╟─fce5cf58-d66c-4fde-b6bb-854f745d1935
# ╟─8fa726b4-7064-4bd3-a2fa-54d875593009
# ╟─675daf21-167e-43a2-b680-a905aaaf1563
# ╟─298dada3-f3a7-4ac1-bdaa-55be8b359e95
# ╟─dc307a3f-c258-49cd-bb46-499da5209f41
# ╟─d6729dc9-0706-4405-9786-0da8ef96fe0a
# ╟─6bd410dd-f851-48d9-a4f8-9ffff975c7a3
# ╟─3e5097fe-5a26-4326-bbcd-1ae95a163c02
# ╟─9e730ef8-2791-4fd7-bd07-8844cd3c2f69
# ╟─fd4f618a-71f2-4976-8515-031e79df3e5b
# ╟─400ee234-919e-4309-8a9a-208df0926d44
# ╟─448aef9e-7b85-4b8f-ba40-7490513dfd1a
# ╟─8b9ac326-884f-4d49-bb09-b01cfa0ae9d3
# ╟─7e316df9-3c1d-47ca-96e7-e79984fc92cf
# ╟─cb6d785c-235d-4c8a-935e-17628c13e850
# ╟─62c1c14e-7094-430a-bcff-74e298d6597e
# ╟─abe6fa93-0105-43e5-9e03-92664b563b38
# ╟─348219b8-8d4c-425b-8773-b42313554eef
# ╟─2ed83178-02a6-4e60-bd33-9df1a74b2f04
# ╟─c3d5177e-5dc3-43da-a419-37b6e58ac49a
# ╟─34d8c7f7-0266-49c8-aac5-ac882d3beb48
# ╟─1b701e22-1766-4113-98e7-f6fc5f3f51f6
# ╟─562de281-2571-4b1f-8363-fcbd02cb3204
# ╟─7a447118-1335-41a5-8f88-9f47a6637061
# ╟─f0b795bd-a6fe-4f80-8b65-f345a5aeb953
# ╟─dca49c6a-a897-442e-8924-7b171e806fc5
# ╟─b969b168-ec64-4a68-99bd-23b7067b0048
# ╟─9ed05f91-a314-4e6c-b05c-8d372d0f2d0f
# ╟─977ba39b-5e9d-4591-a5f0-3b6fc0b5fec4
# ╟─a0af3215-6ecc-4083-afaa-31c476ebae4a
# ╟─2b18e585-71de-4820-8a4a-d46af365789f
# ╟─437de46e-78cd-4b83-9372-6a454c95d135
# ╟─8c4b9294-568c-49bf-a760-c54da18de10d
# ╟─ae72b826-72a7-4c14-8ed6-c5c27f925dd5
# ╟─2e76221f-cec2-443b-b1b4-cf44d93838b3
# ╟─60b59241-c081-4da7-9a87-986d9e5931d1
# ╟─3f620c75-69c9-461a-b8ec-396079c36088
# ╟─beb4b354-3cd6-4a03-b161-0cb1c1845f0b
# ╟─b6c222b6-012b-42ea-967f-fe44a88123b9
# ╟─ff2e0417-8557-4fd7-b03e-0c5aae7882f3
# ╟─0c8d7c37-6dcd-4a8b-b333-073a4a8e99ef
# ╟─66a72bb1-64f1-4fd9-a6df-7d922758e4c4
# ╟─9635fd8d-8ae6-424a-a1c1-803bf7c2dc78
# ╟─6d047903-fa9e-47d4-9147-6518869cc074
# ╟─cfa2509b-38ef-470e-8c49-481e3fdb3909
# ╟─ac751d3e-0dcf-4859-a7b8-6185eeff4b6b
# ╟─6a4974ec-ec57-4e73-a61f-ad83958d2874
# ╟─aef13d6b-d776-44cd-8b91-5a3577af2338
# ╟─2077ceec-2fcb-4c7e-969f-4e2ff9911e9c
# ╟─30e2787d-d1f3-4952-a9ce-534dd51e0f8a
# ╟─e2c6fd53-4fe8-4f1f-81a1-e4008c056b3d
# ╟─67bfd8f9-5874-4205-aa6e-9851d967d939
# ╟─14996238-3aac-4601-a529-e85e182ab028
# ╟─928af98c-90a3-4bce-826d-ff7e96d9c3a8
# ╟─e5a9bd4f-cbe9-44ad-bc29-55d767867fe1
# ╟─2e7bd373-6edc-44a6-8a8f-b46f88277e03
# ╟─727e1c36-6ce2-4114-9831-e7b3981e4ce1
# ╟─6c9e2711-8153-4ebe-b130-c819ff266ff6
# ╟─e33907ec-bcc1-48c0-a09f-cd746b46d3ea
# ╟─c0563fe7-6d8d-4a2d-9e47-fe16dcfaed61
# ╟─d3fb968d-3aa3-44e0-ba8b-13ba61cc6a5b
# ╟─917d6d5e-bc3d-4f24-b51b-e86533e682ab
# ╟─921402f8-a70c-4b45-b134-7fd70f0c699a
# ╟─b9c01bbc-1563-4a58-b2ff-1d70f5f10c43
# ╟─faaaae87-46e9-4fbd-82e0-6ac979f332ee
# ╟─01a5c636-23fb-4e6f-aca5-9bdab11fa66a
# ╟─3e23d630-4e11-4a52-8748-d66b02d1bfd4
# ╟─7275809f-4e12-44aa-b7e1-ec9a2b33f870
# ╟─c24ef65a-7dde-4f06-bfd0-c15e2f769822
# ╟─361360cb-bdf4-4f99-8ccc-3fee22847dd2
# ╟─5fea7742-70a3-4a8e-892d-c70a953b0fcf
# ╟─23e7092b-6006-4ddd-97ff-454128a88e31
# ╟─56d6b975-f6d4-447b-a67b-02954f75286e
# ╟─9ee52d27-ec6b-4e0d-9696-48e9dd88c7ce
# ╟─1771917d-3f40-495d-ad52-50bf674ff0b6
# ╟─76d70fe8-358f-4f2f-9a00-69a147935282
# ╟─c27b5057-3d36-4a80-94f3-d8421874d3b8
# ╟─06b01ce1-94dd-4ddd-ad17-2bdf3aa950ed
# ╟─2423e58f-2ff0-4c80-9666-ccb45243ae19
# ╟─a0bf1aaa-edfb-409f-a2ec-eccc00e9b95f
# ╟─201a91a8-4154-414e-86b1-ca578fa105c2
# ╟─27038fd7-4dc4-4dd5-87dd-0032478d0622
# ╟─14e6f7ed-2a81-4101-a1b5-af627df7c805
# ╟─7c923c8c-9067-42af-b103-391c05bbeb98
# ╟─004efec5-23d3-4940-abff-9024820daf65
# ╟─ac297a30-ce58-4c07-b72f-df4a149dc565
# ╟─8eaece30-202e-4e8b-a16b-adb3375f008c
# ╟─b729c130-5813-4eab-92a1-673a8d29a897
# ╟─cded3cca-c9ac-4d7d-b9dd-4c5497aa955e
# ╟─d4dab771-87f1-4fa2-b6a2-900a51af4586
# ╟─8f3a465e-af54-4b0e-9210-87c140629f2f
# ╟─d61da00e-9d8c-43e8-89c5-e70220dc761a
# ╟─049debc7-b1d5-4908-9b27-70344995a4c4
# ╟─abda6c84-f124-4d61-bb40-0517e28fbcf6
# ╟─72721c2c-f227-469a-91d9-dbec158c2fa7
# ╟─312e0229-445e-42d4-8a0d-709c590c1add
# ╟─97d9ba4b-880f-464e-bd94-7b72a86094b7
# ╟─bf6e7d0a-7e33-47b1-9240-a0af661057f5
# ╟─d16e82d8-faa9-444f-8db7-6f442c5e5fd4
# ╟─dc265679-85cd-4ff1-a728-6353f36e3a9c
# ╟─e36dc8d3-3b4e-46c4-9259-007f75068591
# ╟─4ac1725a-d9e5-4587-9b03-ae8b7379ed56
# ╟─00c3ea64-bbe5-4d7a-a1b2-1197b1455bec
# ╟─432dae1b-89b1-4e8a-b59a-98e00391b368
# ╟─d1eb23f3-7142-493d-b2e6-d4f844e2bfc6
# ╟─398086e4-4a4c-45f6-a32d-cb5d8847233c
# ╟─7c15360a-9f7f-45d0-8059-0420dc46b231
# ╟─cf85e64a-d5c4-4d04-b6ba-04ac003f7289
# ╟─31ef4b01-b5ed-47cc-9ff1-6d92ff7bd2b4
# ╟─d670b261-f427-4498-a8df-fcdacdb14d3e
# ╟─083a0cb1-a597-46ca-84c0-e5b7ce23b53a
# ╟─80176747-6460-4840-992f-394e1c1112b2
# ╟─b0b36b4c-9d44-42cf-a1c2-a97fad25b84e
# ╟─903a6516-2919-4078-89cc-264a726e07ca
# ╟─14623ccd-d970-4046-8e1c-89d1652e3bcf
# ╟─932c04a6-64e3-4d73-a083-c836fbafdbb3
# ╟─fb2d12f6-ebd2-4be5-9506-cdaa52cfaa1e
# ╟─8d63c259-14d0-45db-bd85-93b71e963dbb
# ╟─92383772-0e20-4302-89ca-ccb914a05a33
# ╟─d7e38a5e-2c88-4728-b1cc-d98a5e1a6ec1
# ╟─50e13665-bf79-4931-b545-0050a933e2fa
# ╟─03f0f3c5-cd48-4dec-b379-0d4245235f25
# ╟─0e8e476f-9933-4fd0-9ad6-b01f7918a67b
# ╟─5ec83302-d399-49a5-86fe-514f30d76c7b
# ╟─9860adbf-82c4-4961-a0e4-dd5c51037430
# ╟─68cdb801-d6ca-4fe1-8510-5d66ac78e95e
# ╟─9b1b0269-d975-446a-a168-3db32d0fdb95
# ╟─59bdffc6-b6fd-45f7-98dc-aec5aab8b9a7
# ╟─4ca9e7a6-fa37-4df5-8941-4aa65af2822f
# ╟─9b5dafa0-1ea6-482f-98a8-f2b8bfb7e9f0
# ╟─a89a9f56-8c94-47e0-9588-48ce9dcd97a4
# ╟─81506749-c1b6-4dac-beeb-d551698afb34
# ╟─77b7030e-0cad-4d86-a70e-7896e0e45da7
# ╟─b00301af-7ee3-4266-9878-44616cba7ecd
# ╟─9c8fe1c2-b148-4ded-b5ae-d9c512479a50
# ╟─932d7811-ebb5-4807-8270-afc8905e7b58
# ╟─95c3bcc9-e52f-475e-895b-c8db7f297b8c
# ╟─3115e3a5-886e-4315-9c05-36cf9fe7692e
# ╟─89d87124-23a2-4241-ad68-73b5be83106b
# ╟─73acdb08-b4d2-4e29-8004-1a936e72982f
# ╟─2c8ba6e2-83a9-4c4d-98a5-a1325fba7736
# ╟─5aa2939e-d286-49f8-9601-3ec5fad21a4c
# ╟─138a92e6-98bc-49d9-8ac1-2d75f41daaeb
# ╟─26534a5e-a19b-4ef3-b4b3-1ab10700c601
# ╟─569d7b82-ee46-42e2-b24e-e22272769452
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─011994b7-8b69-49ee-a370-d09600310323
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
