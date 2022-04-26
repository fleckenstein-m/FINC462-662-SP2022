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

# ╔═╡ b9895f07-d73d-4447-ba4a-e5753e4e9f9d
#Set-up packages
begin
	
	using DataFrames, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, XLSX, Luxor, PrettyTables
	
	plotly()
	Plots.PlotlyJSBackend()


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
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Interest Rate Swaps and Floating Rate Bonds
	</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.05cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0.0cm"> </p>
	"""
end

# ╔═╡ 733bbadf-a3ae-46d7-b9fb-6bb6526d74ce
TableOfContents(aside=true, depth=1)

# ╔═╡ 6498b10d-bece-42bf-a32b-631224857753
md"""
# Overview
"""

# ╔═╡ 95db374b-b10d-4877-a38d-1d0ac45877c4
begin
	html"""
	<fieldset>      
        <legend>Goals for today</legend>      
		<br>
<input type="checkbox" value="">Understanding what interest rate swaps and floating rate bonds are.<br><br>
<input type="checkbox" value="">Calculating the fair fixed rate in an interest rate swap contract.<br><br>
<input type="checkbox" value="">Calculating the price and modified duration of a floating rate bond.<br><br>
<input type="checkbox" value="">Relating interest rate swaps, floating rate bonds, and fixed coupon bonds.<br><br>
<input type="checkbox" value="">Calculating the value of an interest rate swap position after inception of the contract.<br><br>
<input type="checkbox" value="">Using interest rate swaps to hedge interest rate exposure.<br><br>
</fieldset>      
	"""
end

# ╔═╡ d1b0ba85-b06b-4f01-af36-4c6f61e72607
md"""
# Interest Rate Swaps
- Each quarter (until maturity), B pays A a fixed payment $C$, which is agreed upon at the start of the interest rate swap contract.
- Each quarter, A pays B a payment that is based on the three-month interest rate at the start of the quarter (usually based on 3-month **LIBOR**).
  - This cash flow is written as $L(t)$
- Typically, there is no upfront payment.
"""

# ╔═╡ b8f54d24-cd72-439c-830d-d536a9e581f8
md"""
##
"""

# ╔═╡ d8af9752-110d-40d8-be95-7dde0ce917e5
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/4)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Fixed Rate Payer (B)",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=3, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(majticks[2], majticks[2] + (0, -50))
		label("C", :N, majticks[2] + (0,-50)) 
		Luxor.arrow(majticks[3], majticks[3] + (0, -50))
		label("C", :N, majticks[3] + (0,-50)) 
		Luxor.arrow(majticks[4], majticks[4] + (0, -50))
		label("C", :N, majticks[4] + (0,-50)) 
		Luxor.arrow(majticks[5], majticks[5] + (0, -50))
		label("C", :N, majticks[5] + (0,-50)) 
		end 900 300
	end
end

# ╔═╡ 8de4a308-e5c0-45f0-b4fe-bc56ccbcf361
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/4)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Rate Payer (A)",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=3, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(majticks[2], majticks[2] + (0, -50))
		label("L(0)", :N, majticks[2] + (0,-50)) 
		Luxor.arrow(majticks[3], majticks[3] + (0, -50))
		label("L(0.25)", :N, majticks[3] + (0,-50)) 
		Luxor.arrow(majticks[4], majticks[4] + (0, -50))
		label("L(0.75)", :N, majticks[4] + (0,-50)) 
		Luxor.arrow(majticks[5], majticks[5] + (0, -50))
		label("L(1.00)", :N, majticks[5] + (0,-50)) 
		
	end 900 300
	end
end

# ╔═╡ 7c8258d1-2b18-49ff-9c6d-beaf815d461f
md"""
# Size of the Interest Rate Swap Market
"""

# ╔═╡ 643ebf9c-707f-4649-b594-5fe63acf32fc
LocalResource("SwapsBIS_01.png",:width => 900)

# ╔═╡ e9d67d83-40a0-4241-8596-7fa40c1b5260
md"""
## Size of OTC Markets
"""

# ╔═╡ 85410abd-c2e3-4a17-840a-59601a76aba9
LocalResource("SwapsBIS_02.png",:width => 900)

# ╔═╡ 796675e8-3235-4228-941b-fc1c72f43181
md"""
Source: [BIS](https://stats.bis.org/statx/toc/DER.html)
"""

# ╔═╡ 7e09e75f-c2e5-4478-96df-b92906802869
md"""
## GE’s Use of Interest Rate Swaps
"""

# ╔═╡ 489c3e6a-8917-4fc1-bb67-8c368544b1e9
LocalResource("./GESwaps_01.png",:width => 560)

# ╔═╡ e3fc4e42-c597-41bf-bf87-62e79e9f5791
md"""
##
"""

# ╔═╡ 48cba890-b045-4358-b248-95249e1599ea
LocalResource("./GESwaps_02.png",:width => 500)

# ╔═╡ 5a61c0ff-e94b-4f1f-8bc4-e89738008fab
md"""
##
"""

# ╔═╡ 85ffe526-f696-44bd-b5a0-d0d0816677af
LocalResource("./GESwaps_03.png",:width => 900)

# ╔═╡ 92686a88-a6ba-4ebe-9f01-46f2338c29db
md"""
##
"""

# ╔═╡ d9e3065d-a753-4f7a-ba3f-6aedc354e51d
LocalResource("GESwaps_04.png",:width => 900)

# ╔═╡ 8d33b72b-a217-46b2-806d-a9ff50986ea0
begin
	rVec_1 = [1.39, 1.53, 1.76, 1.99] #percent
	tVec_1 = [0.25, 0.50, 0.75, 1.00]
	DTVec_1 = 1 ./ (1 .+ rVec_1/400).^(4 .* tVec_1)
	rSwap_1 = 1.9873 #percent
	TSwap_1 = 1
	FSwap_1 = 1000000
	CSwap_1 = rSwap_1/400*FSwap_1
	rSwapCalc_1 = (4*(1-DTVec_1[4])/sum(DTVec_1))*100
	display("")
end

# ╔═╡ c8535a6c-fb32-42ca-b820-2cd6f07355c1
Markdown.parse("
## Example
- Suppose that we decide on 12/31/2017 to enter into a fixed-for-floating interest rate swap. The contract will have the following terms
  - Payment frequency: Quarterly
  - Maturity ``T`` : $(TSwap_1)-year
  - Notional amount ``N``: \$ $(FSwap_1)
  - Reference rate ``r``: we assume that the reference rate is the 3-month Treasury rate.
  - Fixed rate ``f``: $(roundmult(rSwapCalc_1,1e-4)) %
- The zero-coupon yield curve (assume quarterly compounding) on 12/31/2017 was:

Time to maturity ``t``      |  Spot rate ``r``
------:|-------:
$(tVec_1[1])   | $(rVec_1[1]) %
$(tVec_1[2])   | $(rVec_1[2]) %
$(tVec_1[3])   | $(rVec_1[3]) %
$(tVec_1[4])   | $(rVec_1[4]) %
")

# ╔═╡ 16c5d14e-fab0-43a4-8d63-7d29fdf60163
md"""
##
"""

# ╔═╡ 1bca6e3d-7333-4a16-b230-9c38d8d3d6a5
Markdown.parse("
- The fixed cash flow paid *each quarter* is
``\$C = \\frac{f}{4} \\times N = \\frac{$rSwap_1\\%}{4} \\times \$ $FSwap_1 = $(roundmult(CSwap_1,1e-4))\$``
- Suppose we enter the swap as the fixed-rate payer

Cash flow date  |   3/31/2018   | 6/30/2018  |  9/30/2018  | 12/31/2018
---------------:|---------------:|-----------:|------------:|-------------:|
Fixed Leg       | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))``
")

# ╔═╡ 0c3cfb7c-3d36-4ad7-9bf9-7c8f4eaa5d89
md"""
##
"""

# ╔═╡ 40723f3e-c3ac-404f-81d2-5ef6b88327c0
Markdown.parse("
- The end-of-quarter cash flows ``L(t)`` on the floating leg of the contract (which we receive) are calculated using the 3-month Treasury rate at the beginning of the quarter. 
  - This means that L(t) is based on ``r(t-0.25)``.
- Specifically,
Cash flow date  |   3/31/2018   | 6/30/2018  |  9/30/2018  | 12/31/2018
---------------:|---------------:|-----------:|------------:|-------------:|
Floating Leg    |  ``L(3/31/2018)``  | ``L(6/30/2018)`` | ``L(9/30/2018)``  | ``L(12/31/2018)``              |
Based on        | ``r(0.25)`` on 12/31/2017 | ``r(0.25)`` on 3/31/2018 | ``r(0.25)`` on 6/30/2018 | ``r(0.25)`` on 9/30/2018    
")

# ╔═╡ 2d22fed6-c2e5-4ce0-99a1-d82ffa2b822e
md"""
##
"""

# ╔═╡ da277a3f-6778-4f14-89c4-a3b9c93a9fe1
Markdown.parse("
- The first cash flow on the floating leg is calculated using today's 3-month Treasury rate ``r(0.25)=$(rVec_1[1])\\%``.
``\$L(3/31/2018) = \\frac{$(rVec_1[1])\\%}{4} \\times N = \\frac{$(rVec_1[1])\\%}{4} \\times $(FSwap_1) = \$ $(roundmult(FSwap_1*rVec_1[1]/400,1e-4))\$`` 
")

# ╔═╡ bc055004-1bd9-43b6-bb4f-82c9e71fca29
md"""
##
"""

# ╔═╡ bba1c7bd-3761-49b0-afd7-95c512dbb930
Markdown.parse("
- Suppose now that we are on 3/31/2018.
- As the fixed rate payer, we pay a fixed cash flow of ``-$(roundmult(CSwap_1,1e-4))``.
- We receive a cash flow calculated using the 3-month Treasury rate which was set at the beginning of the quarter, i.e. this cash flow is based on the 3-month Treasury rate from three-months before the cash flow date.
  - Suppose that the three-month Treasury rate was 1.73%.
  - This means that the floating payment on 6/30/2018 will be 
``\$L(6/30/2018) = \\frac{1.73\\%}{4} \\times N = \\frac{1.73\\%}{4} \\times $(FSwap_1) = \$ $(roundmult(FSwap_1*1.73/400,1e-4))\$`` 

")

# ╔═╡ 474051a3-76e3-43f0-b3fd-f988a12f081e
md"""
##
"""

# ╔═╡ 13bf94c0-b4d8-4fa4-82ad-6b8f4f5b2e69
Markdown.parse("
- Let's suppose the 3-month Treasury rates on 6/30/2018, and on 9/30/2018 are 1.93% and 2.19% respectively. Thus, the floating rate cash flows are
``\$L(9/30/2018) = \\frac{1.93\\%}{4} \\times N = \\frac{1.93\\%}{4} \\times $(FSwap_1) = \$ $(roundmult(FSwap_1*1.93/400,1e-4))\$`` 
``\$L(12/31/2018) = \\frac{2.19\\%}{4} \\times N = \\frac{2.19\\%}{4} \\times $(FSwap_1) = \$ $(roundmult(FSwap_1*2.19/400,1e-4))\$`` 
")

# ╔═╡ fb1342f6-85d0-4968-a60b-48a91479dc4c
md"""
##
"""

# ╔═╡ fe8c6909-eed7-4c50-8581-1b313f559615
Markdown.parse("
- To summarize, the cash flows to this interest rate swap are
Cash flow date  |   3/31/2018   | 6/30/2018  |  9/30/2018  | 12/31/2018
---------------:|---------------:|-----------:|------------:|-------------:|
Fixed Leg       | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))`` | ``-$(roundmult(CSwap_1,1e-4))``
Floating Leg    |  ``L(3/31/2018)=`` ``$(roundmult(FSwap_1*1.39/400,1e-4))``  | ``L(6/30/2018)``= ``$(roundmult(FSwap_1*1.73/400,1e-4))`` | ``L(9/30/2018)=`` ``$(roundmult(FSwap_1*1.93/400,1e-4))``  | ``L(12/31/2018)=`` ``$(roundmult(FSwap_1*2.19/400,1e-4))``              |
Based on        | ``r(0.25)`` on 12/31/2017 | ``r(0.25)`` on 3/31/2018 | ``r(0.25)`` on 6/30/2018 | ``r(0.25)`` on 9/30/2018   
                | $(rVec_1[1]) %         | $(rVec_1[2]) %      | $(rVec_1[3]) %     | $(rVec_1[4]) %
")

# ╔═╡ 4b0cf5c1-aa94-4e5e-82f3-a328759f08e4
md"""
##
"""

# ╔═╡ 2cc15fab-e9f6-4867-a51c-898c0b3f69da
md"""
- It is important to keep in mind that each floating payment is only know three months in advance.
- When we first signed the contract, 3 of the 4 floating payments were unknown.
"""

# ╔═╡ 921cb531-e0d5-42ed-9ff5-db6d2882c115
md"""
##
"""

# ╔═╡ 333e5ecc-7cff-4fe0-9e70-e810fcb82a93
md"""
- In the example, we were given the interest rate on the fixed leg of the interest rate swap.
- To answer, the question how we can calculate this rate, we will discuss floating rate bonds. This is because knowing how to value floating rate bonds will simplify the calculation of the fixed swap rate.
"""

# ╔═╡ a731528c-1252-449b-951e-3cfb44d7d8f2
md"""
# Floating Rate Bonds
"""

# ╔═╡ fed756b8-8cc7-4225-aa62-28d62905d701
md"""
- The coupon cash flow of a floating rate bond/note (FRN) is based on prevailing interest rates in the market.
- Intuitively, in a plain-vanilla FRN, coupon cash flows payments go up if interest rates go up, and vice versa.
- Typically, the rate to be used to calculate the next coupon cash flow is set ("fixed") at the time of the previous coupon cash flow.
  - The dates on which the next coupon is determined are called *interest reset dates*.
"""

# ╔═╡ b4612e94-58fd-4483-9cab-694520b0d0ca
md"""
##
"""

# ╔═╡ 9d9ea7a2-af76-4e67-afad-5950f062806b
md"""
- Let’s consider an example of a one-year floating rate note (FRN).
- Suppose the FRN pays semi-annual coupon cash flows which are tied to the 6-month Treasury rate set at the beginning of each semi-annual coupon period.
- To show at which point in time spot rates $r(t)$ are known, we will follow the notation that we used for forward rates and write
$$r(T_1,T_2)$$
where $T_1$ is the time at which we know what the spot rate is and $t$ is corresponding maturity from today.
 
"""

# ╔═╡ 45e2bef5-33a7-4b0e-ae13-9ff77e1e605b
md"""
##
"""

# ╔═╡ b87fdef9-b66c-48d3-b09d-37bd5adf3b72
md"""
 - For example:
     - Today's 3-month spot rate which we have written as $r(t)$ is simply $r(0,0.25)$.
     - The six-month spot rate in three months from now is $r(0.25,0.75)$
     - The six-month spot rate in six months from now is $r(0.5,1.00)$
     - The six-month spot rate in one year from now is $r(1.00,1.50)$
"""

# ╔═╡ ce6c871f-63ea-4566-a42f-23a83b1f9ea8
md"""
##
"""

# ╔═╡ 02ad0994-40c8-4d00-9abd-80b027e50636
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/2)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Rate Bond",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(pt2, pt2+(0,-30))
		Luxor.arrow(pt3, pt3+(0,-175))
		label("C=r(0,0.5)/2 * 100", :N, pt2 + (10,-30)) 
        label("C = r(0.5,1.0)/2 * 100", :N, pt3 + (10,-170))   				
		label("+ 100", :N, pt3 + (-50,-140))
		sethue("blue")
		label("r(0,0.5)", :N, pt1 + (10,+65)) 
		label("r(0.5,1.0)", :N, pt2 + (10,+65)) 
	end 950 400
	end
end

# ╔═╡ fcaa3ffb-102d-4e60-a0f9-b216343e368d
md"""
##
"""

# ╔═╡ a525b6bb-3d21-40f7-b2fc-d09fc7bb8952
md"""
- The coupon cash flow paid at time $t=0.5$ is $C = \frac{r(0,0.5)}{2} \times 100$ (known today).
- The coupon cash flow paid at time $t=1.0$ is $C = \frac{r(0.5,1.0)}{2} \times 100$ (unknown today)
"""

# ╔═╡ e666b292-9df8-4230-86e3-4137459bab0c
md"""
##
"""

# ╔═╡ da851641-f6c8-4e29-8e8f-36cab8b6e81d
md"""
- Suppose that $r(0, 0.5)=4\%$. 
  - We get to observe this rate today.
- Suppose also that $r(0.5,1)=6\%$. 
  - We do not get to observe this today, but find this out at time $t=0.5$. At time 0, r (0.5, 1) is unknown.
"""

# ╔═╡ 860219f3-e654-49e8-80d2-d41270e74ac0
md"""
##
"""

# ╔═╡ d7352f66-0ae8-4aa3-b9c0-b7002a820a26
begin
	let
		r_00_05=4
		r_05_10=6
		CF_05 = r_00_05/200*100
		CF_10 = r_05_10/200*100
		
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/2)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Rate Bond",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(pt2, pt2+(0,-30))
		Luxor.arrow(pt3, pt3+(0,-175))
		label("C=$CF_05", :N, pt2 + (10,-30)) 
        label("C=$CF_10  + 100", :N, pt3 + (10,-180))   				
		sethue("blue")
		label("r(0,0.5)=$r_00_05 %", :N, pt1 + (10,+65)) 
		label("r(0.5,1.0)=$r_05_10 %", :N, pt2 + (10,+65)) 
	end 950 400
	end
end

# ╔═╡ ef3cffd5-2161-41f1-a695-a92dc5ec2c02
md"""
## Valuing a Floating Rate Note (FRN)
"""

# ╔═╡ adb60bdb-5c04-454b-8ca7-fc6563f9fb70
md"""
- Suppose we are in six months from now at $t=0.5$.
- The first coupon has been paid, and there is one cash flow left which occurs at $t=1.0$.
"""

# ╔═╡ c9afd2f8-e6de-4350-a3e6-a92d435a5c4b
md"""
##
"""

# ╔═╡ 1a2bdfb7-6772-4240-8b2a-8d8cdca69d75
begin
	let
		r_00_05=4
		r_05_10=6
		CF_05 = r_00_05/200*100
		CF_10 = r_05_10/200*100
		
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/2)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Rate Bond",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(pt3, pt3+(0,-175))
		label("C=$CF_10  + 100", :N, pt3 + (10,-180))   				
		sethue("blue")
		label("r(0.5,1.0)=$r_05_10 %", :N, pt2 + (10,+65)) 
		circle(pt2, 12, :stroke)
	end 950 400
	end
end

# ╔═╡ 544fbaa3-c44e-4313-9d4d-c85c313740a4
md"""
##
"""

# ╔═╡ 7e08d13b-75e3-495e-a562-f1deddb04333
md"""
- The FRN has now six months to maturity.
- The final cash flow is
$$C + 100 = \frac{r(0.5,1)}{2} \times 100 + 100 = 100 \times \left( 1 +\frac{r(0.5,1) }{2}\right)$$

"""

# ╔═╡ b1e22280-26b3-43a8-bbfa-c0e43adc8dbf
md"""
##
"""

# ╔═╡ d769a15c-4a0d-4136-871c-5418718b785a
md"""
- The key is that $r(0.5,1)$ is known if we are at t=0.5.
- The value of the FRN at $t=0.5$ is the present value of the final cash flow. 
- We know what the final cash flow is and what the discount rate is since $r(0.5,1)$ is known.
- Thus, the value of the FRN $P(t)$ at $t=0.5$ is

$$P(0.5) = \frac{C+100}{\left(1+\frac{r(0.5,1)}{2}\right)^{2\times 0.5}} = \frac{100 \times \left( 1 +\frac{r(0.5,1) }{2}\right)}{\left(1+\frac{r(0.5,1)}{2}\right)^{1}}=100$$

- Thus, the bond is trading at par.
"""

# ╔═╡ f4711422-f99c-4458-a780-673db01791ca
md"""
##
"""

# ╔═╡ dc64e11a-683b-4e53-9e35-8168919c0ab7
md"""
- Next, suppose we are back at $t=0$.
- In the previous step, we derived that the value of the FRN at $t=0.5$ will be 100, right after the coupon cash flow is paid.
- Thus, the value today $P(0)$ of the FRN is the present value of 100 plus the coupon cash flow of $C=\frac{r(0.5,1)}{2} \times 100$.
$$P(0) = \frac{C+100}{\left(1+\frac{r(0,0.5)}{2}\right)^{2\times 0.5}}=\frac{\left(\frac{r(0.5,1)}{2} \times 100\right)+100}{\left(1+\frac{r(0,0.5)}{2}\right)^{1}}=\frac{\left(1+\frac{r(0.5,1)}{2}\right)\times 100}{\left(1+\frac{r(0,0.5)}{2}\right)^{1}}=100$$
"""

# ╔═╡ 4221e262-def1-45fd-a680-0c99014c34ca
md"""
##
"""

# ╔═╡ e71e0f8b-dbb1-413a-bb95-77c7bf4f5938
md"""
- The key takeaway is that just after interest reset dates, a floating rate note has a market value equal to its face value.
- This is true for floating rate Treasury bonds of arbitrary maturities as long as the coupon rate is based on Treasury rates.
- Another important property of floating rate bonds is their prices do not flucuate much in response to changes in interest rates. 
"""

# ╔═╡ c636290f-1745-49f1-a8fa-fbc32394e198
md"""
## Interest Rate Sensitivity of Floating Rate Notes
"""

# ╔═╡ ac65ead2-7393-4bd2-bae9-5916f45d29a4
md"""
- To illustrate, suppose that we buy a 5-year FRN with semi-annual coupons and $r(0, 0.5) = 4\%$. The reset has just occurred.
- The first coupon will be \$2, even if interest rates change tomorrow.
- The value of the bond will be \$100 right after the next coupon reset (in 0.5 years).
- The current price of the bond is \$100 since we are just after a coupon reset date and interest rates have not changed yet.
- Let's calculate the modified duration (MD) of the FRN.
"""

# ╔═╡ 6b02f982-f281-4667-8d36-b40175c5821d
md"""
##
"""

# ╔═╡ 49c5f161-57e7-4996-9a6a-75c3c20cb405
md"""
- Recall that the modified duration (MD) can be calculated as
- Let's use $\Delta y=0.001$
$$MD = - \frac{P(y+\Delta y)-P(y-\Delta y)}{2 \times \Delta y} \times \frac{1}{P(y)}$$
$$P(y) = \frac{100+2}{1+\frac{0.04}{2}}=100$$
$$P(y+\Delta y) = \frac{100+2}{1+\frac{0.04+0.001}{2}}=99.95100441$$
$$P(y-\Delta y) = \frac{100+2}{1+\frac{0.04-0.001}{2}}=100.0490436$$
$$MD = -\frac{99.95100441−100.0490436}{2\times 0.001} \times \frac{1}{100}=0.4902$$
- As a rule of thumb, the modified duration of a FRN is the time to the next interest rate reset.
"""

# ╔═╡ 3efe7640-b582-4d21-a9bb-15ef90968d19
md"""
## Interest Rate Swaps: Solving for the fair fixed rate
"""

# ╔═╡ a8eb8f9f-0a2c-4182-b154-e8774411b1da
md"""
- Suppose that we decide on 12/31/2017 to enter into a fixed-for-floating interest rate swap. The contract will have the following terms
 - Payment frequency: Quarterly
  - Maturity ``T`` : $(TSwap_1)-year
  - Notional amount ``N``: \$ $(FSwap_1)
  - Reference rate ``r``: we assume that the reference rate is the 3-month Treasury rate.
  - Fixed rate ``f``: $(roundmult(rSwapCalc_1,1e-4)) %

"""

# ╔═╡ eb10aabc-6fe0-4780-b693-1e8661897559
md"""
##
"""

# ╔═╡ 581532bb-c94e-40e2-9225-6cdc3b104bf9
md"""
- The zero-coupon yield curve on 12/31/2017 was as shown below. Assume quarterly compounding.

Time to maturity $t$      |  Spot rate $r$
------:|-------:
$(tVec_1[1])   | $(rVec_1[1])%
$(tVec_1[2])    | $(rVec_1[2])%
$(tVec_1[3])   | $(rVec_1[3])%
$(tVec_1[4])      | $(rVec_1[4])%
- Without loss of generality, let's assume that the fixed and the floating leg exchange the notional amount $N$ at maturity.
"""

# ╔═╡ 38050bcf-2d8a-4449-89e9-2bb3b1c9f2ff
md"""
##
"""

# ╔═╡ cd2c4d02-3ef6-484f-9513-3f7bd3d950b5
md"""
- Consider the floating leg of the swap first.
"""

# ╔═╡ 951fef4c-97e4-46b7-aea3-61d893ad45b7
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/4)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Leg",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=3, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(majticks[2], majticks[2]+(0,-30))
		Luxor.arrow(majticks[3], majticks[3]+(0,-30))
		Luxor.arrow(majticks[4], majticks[4]+(0,-30))
		Luxor.arrow(majticks[5], majticks[5]+(0,-30))
		Luxor.arrow(majticks[5]+(3,0), majticks[5]+(3,-150))
		label("L(0.25)", :N, majticks[2] + (0,-30)) 
		label("L(0.50)", :N, majticks[3] + (0,-30)) 
		label("L(0.75)", :N, majticks[4] + (0,-30)) 
		label("L(1.00)", :N, majticks[5] + (0,-30)) 
		label("N", :N, majticks[5] + (3,-160)) 
		sethue("blue")
		label("r(0,0.25)", :N, majticks[2] + (10,+65)) 
		label("r(0.25,0.5)", :N, majticks[3]  + (10,+65)) 
		label("r(0.5,0.75)", :N, majticks[4]  + (10,+65)) 
		label("r(0.75,1.00)", :N, majticks[5]  + (10,+65)) 
	end 950 400
	end
end

# ╔═╡ 0126f9d5-4c80-422c-9a9f-c8a5cefd4caf
md"""
##
"""

# ╔═╡ eb56521d-7716-4884-9849-3f2737d3b5b3
md"""
- The cash flows on the floating leg of the swap are similar to a floating rate note.
- Thus, we know that the value today at $t=0$ of the floating leg is equal to the notional $N$.
$$P_{\textrm{Floating}} = N$$
"""

# ╔═╡ 548c7fc8-268d-41b9-a68a-344a939bc3f1
md"""
- Let's next turn to the fixed leg of the swap.
"""

# ╔═╡ ecf7e394-ee00-48a2-9f63-52e9320dcafb
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=$(n/4)", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Fixed Leg",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=3, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(majticks[2], majticks[2]+(0,-30))
		Luxor.arrow(majticks[3], majticks[3]+(0,-30))
		Luxor.arrow(majticks[4], majticks[4]+(0,-30))
		Luxor.arrow(majticks[5], majticks[5]+(0,-30))
		Luxor.arrow(majticks[5]+(3,0), majticks[5]+(3,-150))
		label("C", :N, majticks[2] + (0,-30)) 
		label("C", :N, majticks[3] + (0,-30)) 
		label("C", :N, majticks[4] + (0,-30)) 
		label("C", :N, majticks[5] + (0,-30)) 
		label("N", :N, majticks[5] + (3,-160)) 
		sethue("blue")
		label("r(0,0.25)", :N, majticks[2] + (10,+65)) 
		label("r(0.25,0.5)", :N, majticks[3]  + (10,+65)) 
		label("r(0.5,0.75)", :N, majticks[4]  + (10,+65)) 
		label("r(0.75,1.00)", :N, majticks[5]  + (10,+65)) 
	end 950 400
	end
end

# ╔═╡ 4f450508-1b62-460a-b5b8-ea75dae43b2e
md"""
##
"""

# ╔═╡ 2a34d810-72df-4c5a-8362-891e4cf683e8
Markdown.parse("
- The cash flows on the fixed leg of the swap mirror those of a fixed-rate coupon bond.
- Recall that the term structure was given as
Time to maturity ``t``      |  Spot rate ``r``
------:|-------:
0.25   | 1.39%
0.5    | 1.53%
0.75   | 1.76%
1      | 1.99%



")

# ╔═╡ 16a369db-1212-4b9e-ba36-a14c468f2d06
md"""
##
"""

# ╔═╡ e63a4351-ff12-4b8a-a56f-48ab529bb71c
Markdown.parse("
- Thus, the value of the fixed leg is
``\$P_{\\textrm{Fixed}} = \\frac{C}{\\left(1+\\frac{r_{0.25}}{4}\\right)^{4\\times 0.25}} + \\frac{C}{\\left(1+\\frac{r_{0.50}}{4}\\right)^{4\\times 0.50}} + \\frac{C}{\\left(1+\\frac{r_{0.75}}{4}\\right)^{4\\times 0.75}} + \\frac{C+N}{\\left(1+\\frac{r_{1.00}}{4}\\right)^{4\\times 1.00}}\$``

``\$P_{\\textrm{Fixed}} = \\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[1],1e-4))\\%}{4}\\right)^{4\\times 0.25}} + \\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[2],1e-4))\\%}{4}\\right)^{4\\times 0.50}} + \\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[3],1e-4))\\%}{4}\\right)^{4\\times 0.75}} + \\frac{C+$(FSwap_1)}{\\left(1+\\frac{$(roundmult(rVec_1[4],1e-4))\\%}{4}\\right)^{4\\times 1.00}}\$``
")

# ╔═╡ 76db86f2-a742-4fb8-b9db-15a3e37d130a
md"""
##
"""

# ╔═╡ 656ac3da-be2f-46b8-9315-5eee010df3d7
Markdown.parse("
- At the start of the interest rate swap at time ``t=0``, the value of the fixed leg is equal to the value of the floating leg.
  - Recall that no cash flows occur at time ``t=0``.
- Thus, setting both sides equal
``\$P_{\\textrm{Fixed}} \\stackrel{!}{=} P_{\\textrm{Floating}}\$``

``\$\\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[1],1e-4))\\%}{4}\\right)^{1}} + \\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[2],1e-4))\\%}{4}\\right)^{2}} + \\frac{C}{\\left(1+\\frac{$(roundmult(rVec_1[3],1e-4))\\%}{4}\\right)^{3}} + \\frac{C+$(FSwap_1)}{\\left(1+\\frac{$(roundmult(rVec_1[4],1e-4))\\%}{4}\\right)^{4}} \\stackrel{!}{=} $(FSwap_1)\$``


")

# ╔═╡ 5feda40a-449e-4d75-89e5-d0a7d9897dd3
md"""
##
"""

# ╔═╡ e6b11140-f56c-420d-9854-1d23b0747549
Markdown.parse("
- Solving for the cash flow ``C`` gives us 
``\$C = $(roundmult(FSwap_1*rSwapCalc_1/4,1e-2))\$``
- and since ``C=\\frac{1}{4}\\times f \\times N``
- the fair swap rate is 
``\$f=$(roundmult(rSwapCalc_1,1e-4))\\%\$``

")

# ╔═╡ 6ea82348-17f4-4821-85e6-4159d23be0cf
md"""
##
"""

# ╔═╡ fc2b1421-21fe-4379-a920-7121cabc9f56
Markdown.parse("
- **Can we use discount factors to make the calculation less convoluted?**
- Consider again the fixed leg of the interest rate swap.

``\$P_{\\textrm{Fixed}} = \\frac{C}{\\left(1+\\frac{r_{0.25}}{4}\\right)^{4\\times 0.25}} + \\frac{C}{\\left(1+\\frac{r_{0.50}}{4}\\right)^{4\\times 0.50}} + \\frac{C}{\\left(1+\\frac{r_{0.75}}{4}\\right)^{4\\times 0.75}} + \\frac{C+N}{\\left(1+\\frac{r_{1.00}}{4}\\right)^{4\\times 1.00}}\$``

- Recall that the discount factor ``D(T)`` (quarterly compounded) os
``\$D(T) = \\frac{1}{\\left(1+\\frac{r_T}{4}\\right)^{4\\times T}} \$``
  - For instance, the 3-month discount factor is
``\$D(0.25) = \\frac{1}{\\left(1+\\frac{r_{0.25}}{4}\\right)^{4\\times 0.25}} \$``
")

# ╔═╡ 7c589329-a544-4dd8-ac2f-2167e76228bd
md"""
##
"""

# ╔═╡ 347f6c88-1884-4102-b405-400c38e484d9
Markdown.parse("
- Thus, let's rewrite the value of the fixed leg using discount factors.
``\$P_{\\textrm{Fixed}} = C\\times D(0.25) + C\\times D(0.5) + C\\times D(0.75) + (C+N)\\times D(1.0) \$``
- Next, recall that that interest rate swap was fairly valued, such that ``P_{\\textrm{Fixed}}\\stackrel{!}{=}P_{\\textrm{Floating}}``
- We know that the value of the floating leg is par, ``P_{\\textrm{Floating}}=N``
- Thus, 
``\$N = C\\times D(0.25) + C\\times D(0.5) + C\\times D(0.75) + (C+N)\\times D(1.0) \$``
- Let's solve for the cash flow on the fixed leg of the swap ``C``
``\$C = N \\times \\frac{1-D(1.0)}{D(0.25)+D(0.50)+D(0.75)+D(1.0)}\$``
")

# ╔═╡ 2cbd81a0-6a6f-4fab-9cd6-4a41497ca8ae
md"""
##
"""

# ╔═╡ bab657f8-4984-4cdd-93c7-b4ed90f2f86d
Markdown.parse("
- This equation gives us the *cash flow* on the fixed leg of the interest rate swap.
- To get the fair *swap rate*, let's use that the cash flow is
``\$C=\\frac{f}{4}\\times N\$``
- Plugging in the expression for ``C``
``\$\\frac{f}{4}\\times N = N \\times \\frac{1-D(1.0)}{D(0.25)+D(0.50)+D(0.75)+D(1.0)}\$``
- Thus, we have an equation for the fixed rate ``f`` on an interest rate swap.
``\$f = 4\\times \\frac{1-D(1.0)}{D(0.25)+D(0.50)+D(0.75)+D(1.0)}\$``
")

# ╔═╡ a3c079f6-2e0a-427c-a943-5b9ff2986bda
md"""
##
"""

# ╔═╡ 9158d289-811b-459b-853c-e0fe96894750
Markdown.parse("
- Let's use this insight and calculate the fixed rate on the interest rate swap (which we already know is ``f=$(roundmult(rSwapCalc_1,1e-4))\\%``.
- To begin, let's take the spot rates we are given and calculate the discount factors.

")

# ╔═╡ a1bad7a1-bf87-4372-a07c-72a5802cbf7e
md"""
##
"""

# ╔═╡ cf3b892d-a0bc-4acf-b191-79ce97d77f59
Markdown.parse("
- Let's consider again the spot rates we are given and let's calculate the discount factors.
Time to maturity ``t``      |  Spot rate ``r``   | Discount Factor ``D(t)`` | Calculation
------:|-------:|-------------------------------:|----------------------:
$(tVec_1[1])   | $(rVec_1[1])%  | $(roundmult(DTVec_1[1],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_1[1])\\%/4 \\right)^{4 \\times $(tVec_1[1])}}\$``
$(tVec_1[2])    | $(rVec_1[2])% | $(roundmult(DTVec_1[2],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_1[2])\\%/4 \\right)^{4 \\times $(tVec_1[2])}}\$``
$(tVec_1[3])   | $(rVec_1[3])%  | $(roundmult(DTVec_1[3],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_1[3])\\%/4 \\right)^{4 \\times $(tVec_1[3])}}\$``
$(tVec_1[4])      | $(rVec_1[4])% | $(roundmult(DTVec_1[4],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_1[4])\\%/4 \\right)^{4 \\times $(tVec_1[4])}}\$`` 
")

# ╔═╡ 8be141ab-1c8a-412c-8b80-6954f118e633
md"""
##
"""

# ╔═╡ 8f350713-f1d7-4b0c-8036-d6b70186de0e
Markdown.parse("
- Thus, the fair rate on the fixed leg of the interest rate swap ``f`` is
``\$f = 4\\times \\frac{1-D(1.0)}{D(0.25)+D(0.50)+D(0.75)+D(1.0)}\$``
``\$f = 4\\times \\frac{1-$(roundmult(DTVec_1[4],1e-4))}{$(roundmult(DTVec_1[1],1e-4))+$(roundmult(DTVec_1[2],1e-4))+$(roundmult(DTVec_1[3],1e-4))+$(roundmult(DTVec_1[4],1e-4))}=$(roundmult(rSwap_1,1e-4))\\%\$``

")

# ╔═╡ 795d443d-685f-48cc-b489-be45774b7c8a
begin
 tVec_2 = [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0]
 rVec_2 = [5.50,5.62,5.64,5.65,5.69,5.74,5.80,5.86,5.91,5.96,6.01,6.06]	
 
 pvAnn_2 = sum(1 ./ ( 1 .+ rVec_2./400).^(4 .* tVec_2))
 F_2 = 500000
 C_2 = F_2*(1-1/(1+rVec_2[end]/400)^(4*tVec_2[end]))/pvAnn_2
 DTVec_2 = 1 ./ (1 .+ rVec_2/400).^(4 .* tVec_2)
 rswap_2 = 4*(1-DTVec_2[end])/(sum(DTVec_2))	
 display("")	
end

# ╔═╡ 91ccf353-fff5-4eb1-a0c3-99f45f024e35
md"""
## Example
- Suppose we need to determine the fair rate $f$ on a three-year interest rate swap with \$50 million notional.
- Suppose the yield curve today is
Time to maturity $t$   | Spot rate $r(0,t)$
----------------------:|--------------------:
$(tVec_2[1]) | $(rVec_2[1])%
$(tVec_2[2])  | $(rVec_2[2])%
$(tVec_2[3]) | $(rVec_2[3])%
$(tVec_2[4])    | $(rVec_2[4])%
$(tVec_2[5]) | $(rVec_2[5])%
$(tVec_2[6])  | $(rVec_2[6])%
$(tVec_2[7]) | $(rVec_2[7])%
$(tVec_2[8])    | $(rVec_2[8])%
$(tVec_2[9]) | $(rVec_2[9])%
$(tVec_2[10]) | $(rVec_2[10])%
$(tVec_2[11]) | $(rVec_2[11])%
$(tVec_2[12]) | $(rVec_2[12])%

"""

# ╔═╡ 1464e93f-4c7c-46ee-8902-eb7a2c3e9eb9
md"""
##
"""

# ╔═╡ dfd3169d-2fd4-4c44-846b-72fbb66df4a0
Markdown.parse("
- Let's get the discount factors first.
- Let's consider again the spot rates we are given and let's calculate the discount factors.
Time to maturity ``t``      |  Spot rate ``r``   | Discount Factor ``D(t)`` | Calculation
------:|-------:|-------------------------------:|----------------------:
$(tVec_2[1])   | $(rVec_2[1])%  | $(roundmult(DTVec_2[1],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_2[1])\\%/4 \\right)^{4 \\times $(tVec_2[1])}}\$``
$(tVec_2[2])    | $(rVec_2[2])% | $(roundmult(DTVec_2[2],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_2[2])\\%/4 \\right)^{4 \\times $(tVec_2[2])}}\$``
$(tVec_2[3])   | $(rVec_2[3])%  | $(roundmult(DTVec_2[3],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_2[3])\\%/4 \\right)^{4 \\times $(tVec_2[3])}}\$``
$(tVec_2[4])      | $(rVec_2[4])% | $(roundmult(DTVec_2[4],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[4])\\%/4 \\right)^{4 \\times $(tVec_2[4])}}\$`` 
$(tVec_2[5])      | $(rVec_2[5])% | $(roundmult(DTVec_2[5],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[5])\\%/4 \\right)^{4 \\times $(tVec_2[5])}}\$`` 
$(tVec_2[6])      | $(rVec_2[6])% | $(roundmult(DTVec_2[6],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[6])\\%/4 \\right)^{4 \\times $(tVec_2[6])}}\$`` 
$(tVec_2[7])      | $(rVec_2[7])% | $(roundmult(DTVec_2[7],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[7])\\%/4 \\right)^{4 \\times $(tVec_2[7])}}\$`` 
$(tVec_2[8])      | $(rVec_2[8])% | $(roundmult(DTVec_2[8],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[8])\\%/4 \\right)^{4 \\times $(tVec_2[8])}}\$`` 
$(tVec_2[9])      | $(rVec_2[9])% | $(roundmult(DTVec_2[9],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[9])\\%/4 \\right)^{4 \\times $(tVec_2[9])}}\$`` 
$(tVec_2[10])      | $(rVec_2[10])% | $(roundmult(DTVec_2[10],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[10])\\%/4 \\right)^{4 \\times $(tVec_2[10])}}\$`` 
$(tVec_2[11])      | $(rVec_2[11])% | $(roundmult(DTVec_2[11],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[11])\\%/4 \\right)^{4 \\times $(tVec_2[11])}}\$`` 
$(tVec_2[12])      | $(rVec_2[12])% | $(roundmult(DTVec_2[12],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_2[12])\\%/4 \\right)^{4 \\times $(tVec_2[12])}}\$`` 
")

# ╔═╡ fc6dfca0-a94f-4545-abb4-ea04976d250b
md"""
##
"""

# ╔═╡ ebd8cf3b-ff6f-45b1-b26a-11ec231473da
Markdown.parse("
- Next, we use that the fair swap rate ``f`` of a ``T``-year interest rate swap (with quarterly cash flows) can be calculated using discount factors ``D(t)`` as

``\$f = 4\\times \\frac{1-D(T)}{D(0.25)+D(0.50)+D(0.75)+\\ldots+D(T)}\$``

- Thus, the fair rate ``f`` on the fixed leg of the ``$(tVec_2[end])``-year interest rate swap is
``\$f = 4\\times \\frac{1-D($(tVec_2[end]))}{D(0.25)+D(0.50)+\\ldots +D($(tVec_2[end]))}\$``
``\$f = 4\\times \\frac{1-$(roundmult(DTVec_2[end],1e-4))}{$(roundmult(DTVec_1[1],1e-4))+$(roundmult(DTVec_1[2],1e-4))+$(roundmult(DTVec_1[3],1e-4))+\\ldots + $(roundmult(DTVec_1[end],1e-4))}=$(roundmult(rswap_2*100,1e-4))\\%\$``
- The quarterly cash flows ``C`` on the fixed leg are
``\$C=N \\times \\frac{f}{4} = $(roundmult(F_2,1e-4)) \\times \\frac{$(roundmult(rswap_2*100,1e-4))\\%}{4} = $(roundmult(rswap_2/4*F_2,1e-4))\$``
")

# ╔═╡ 59d69a62-217e-4ac2-9052-40cc9031c796
md"""
## Valuing an Interest Rate Swap after Inception
"""

# ╔═╡ 8f1a6fa6-6fc4-4331-84b1-2b999e1fb111
md"""
- We know that when the interest rate swap is executed (at inception of the contract), the value of the fixed leg is equal to the value of the floating leg.
- After some time passes, however, it is not necessarily the case that the values of fixed and floating remain equal.
- We will illustrate this next.
"""

# ╔═╡ d65b73eb-fffd-4184-b690-cf45dcd6e175
begin
 tVec_3 = [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0]
 rVec_3 = [5.50,5.62,5.64,5.65,5.69,5.74,5.80,5.86,5.91,5.96,6.01,6.06].+1.0	
 
 pvAnn_3 = sum(1 ./ ( 1 .+ rVec_3./400).^(4 .* tVec_3))
 F_3 = 500000
 C_3 = F_3*(1-1/(1+rVec_3[end]/400)^(4*tVec_3[end]))/pvAnn_3
 DTVec_3 = 1 ./ (1 .+ rVec_3/400).^(4 .* tVec_3)
 rswap_3 = 4*(1-DTVec_3[end])/(sum(DTVec_3))	
 display("")	
end

# ╔═╡ 13705228-b1d5-4baa-99d1-810543950668
md"""
##
"""

# ╔═╡ 37d85758-2a7c-461e-bf01-333cbdeca02e
md"""
- Suppose that all spot rates increase by one percentage point in the instant right after the contract is agreed to.
Time to maturity $t$   | Spot rate $r(0,t)$
----------------------:|--------------------:
$(tVec_3[1]) | $(rVec_3[1])%
$(tVec_3[2])  | $(rVec_3[2])%
$(tVec_3[3]) | $(rVec_3[3])%
$(tVec_3[4])    | $(rVec_3[4])%
$(tVec_3[5]) | $(rVec_3[5])%
$(tVec_3[6])  | $(rVec_3[6])%
$(tVec_3[7]) | $(rVec_3[7])%
$(tVec_3[8])    | $(rVec_3[8])%
$(tVec_3[9]) | $(rVec_3[9])%
$(tVec_3[10]) | $(rVec_3[10])%
$(tVec_3[11]) | $(rVec_3[11])%
$(tVec_3[12]) | $(rVec_3[12])%
"""

# ╔═╡ 3f82e165-635d-4b40-9d72-68051eb34e0f
md"""
##
"""

# ╔═╡ 1426fadd-f442-405c-8857-8f0619b4d7e7
Markdown.parse("
- However, we have agreed to pay the fixed rate ``f=$(roundmult(rswap_2*100,1e-4))\\%``.
- Specifically, each quarter, we pay a fixed cash flow ``C`` equal to 
``\$C=N \\times \\frac{f}{4} = $(roundmult(F_2,1e-4)) \\times \\frac{$(roundmult(rswap_2*100,1e-4))\\%}{4} = $(roundmult(rswap_2/4*F_2,1e-4))\$``
")

# ╔═╡ 87339f91-30f2-4604-be23-1159a6b1dfd5
md"""
##
"""

# ╔═╡ e2830e26-266e-43c8-a506-a64616b5a8e9
begin
	let
			
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Fixed Leg",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=3,
		    major=11)
		sethue("green")
		for i=2:length(majticks)-1
			Luxor.arrow(majticks[i], majticks[i]+(0,-30))
			label("C", :N, majticks[i] + (0,-30)) 
		end
		Luxor.arrow(majticks[end], majticks[end]+(0,-80))
		label("C+N", :N, majticks[end] + (0,-80)) 
		
	end 950 400
	end
end

# ╔═╡ 533b873d-a828-42a5-8412-2bf79a1af169
md"""
##
"""

# ╔═╡ 46a01c46-54f7-4f86-b3ee-cfc9ef4515ac
Markdown.parse("
- The cash flow stream ``C`` is analogous to fixed-rate coupon bond with quarterly coupon cash flows and $(tVec_3[end]) years to maturity.
- We calculate the present value of this cash flow stream by discounting the cash flows ``C`` using the new spot rates.
- Let's first calculate the discount factors.
")

# ╔═╡ f594b900-1d22-4c10-927e-bae7e82596c6
md"""
##
"""

# ╔═╡ 88aaa19a-b4e2-4b5a-9e6e-db5d5e272036
Markdown.parse("
- Let's get the discount factors first.
- Let's consider again the spot rates we are given and let's calculate the discount factors.
Time to maturity ``t``      |  Spot rate ``r``   | Discount Factor ``D(t)`` | Calculation
------:|-------:|-------------------------------:|----------------------:
$(tVec_3[1])   | $(rVec_3[1])%  | $(roundmult(DTVec_3[1],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_3[1])\\%/4 \\right)^{4 \\times $(tVec_3[1])}}\$``
$(tVec_3[2])    | $(rVec_3[2])% | $(roundmult(DTVec_3[2],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_3[2])\\%/4 \\right)^{4 \\times $(tVec_3[2])}}\$``
$(tVec_3[3])   | $(rVec_3[3])%  | $(roundmult(DTVec_3[3],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_3[3])\\%/4 \\right)^{4 \\times $(tVec_3[3])}}\$``
$(tVec_3[4])      | $(rVec_3[4])% | $(roundmult(DTVec_3[4],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[4])\\%/4 \\right)^{4 \\times $(tVec_3[4])}}\$`` 
$(tVec_3[5])      | $(rVec_3[5])% | $(roundmult(DTVec_3[5],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[5])\\%/4 \\right)^{4 \\times $(tVec_3[5])}}\$`` 
$(tVec_3[6])      | $(rVec_3[6])% | $(roundmult(DTVec_3[6],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[6])\\%/4 \\right)^{4 \\times $(tVec_3[6])}}\$`` 
$(tVec_3[7])      | $(rVec_3[7])% | $(roundmult(DTVec_3[7],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[7])\\%/4 \\right)^{4 \\times $(tVec_3[7])}}\$`` 
$(tVec_3[8])      | $(rVec_3[8])% | $(roundmult(DTVec_3[8],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[8])\\%/4 \\right)^{4 \\times $(tVec_3[8])}}\$`` 
$(tVec_3[9])      | $(rVec_3[9])% | $(roundmult(DTVec_3[9],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[9])\\%/4 \\right)^{4 \\times $(tVec_3[9])}}\$`` 
$(tVec_3[10])      | $(rVec_3[10])% | $(roundmult(DTVec_3[10],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[10])\\%/4 \\right)^{4 \\times $(tVec_3[10])}}\$`` 
$(tVec_3[11])      | $(rVec_3[11])% | $(roundmult(DTVec_3[11],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[11])\\%/4 \\right)^{4 \\times $(tVec_3[11])}}\$`` 
$(tVec_3[12])      | $(rVec_3[12])% | $(roundmult(DTVec_3[12],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_3[12])\\%/4 \\right)^{4 \\times $(tVec_3[12])}}\$`` 
")

# ╔═╡ 21c6be91-61e7-4550-9478-2a5c78587506
md"""
##
"""

# ╔═╡ fdaa19eb-a225-4315-8a28-6ecd8cde8caa
Markdown.parse("
``\$P_{\\textrm{Fixed}}=C\\times D(0.25) + C\\times D(0.5) + C\\times D(0.75) +\\ldots + (C+N)\\times D(3.0)\$``
``\$P_{\\textrm{Fixed}}=$(roundmult(rswap_2/4*F_2,1e-2))\\times $(roundmult(DTVec_3[1],1e-4)) + $(roundmult(rswap_2/4*F_2,1e-2))\\times $(roundmult(DTVec_3[2],1e-4)) + $(roundmult(rswap_2/4*F_2,1e-2))\\times $(roundmult(DTVec_3[3],1e-4)) +\\ldots + ($(roundmult(rswap_2/4*F_2,1e-2))+$(roundmult(F_2,1e-2)))\\times $(roundmult(DTVec_3[end],1e-4)) = $(roundmult((rswap_2/4*F_2)*sum(DTVec_3)+F_2*DTVec_3[end],1e-4))\$``

")

# ╔═╡ 82c8d26d-c641-472a-8543-36e2de2647d7
md"""
##
"""

# ╔═╡ 8764cabf-4a00-418c-b812-53a791572338
begin
	let
			
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Floating Leg",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=3,
		    major=11)
		sethue("green")
		for i=2:length(majticks)-1
			Luxor.arrow(majticks[i], majticks[i]+(0,-30))
			label("L", :N, majticks[i] + (0,-30)) 
		end
		Luxor.arrow(majticks[end], majticks[end]+(0,-80))
		label("L+N", :N, majticks[end] + (0,-80)) 
		
	end 950 400
	end
end

# ╔═╡ 8b88cee6-3643-4277-b2bc-9568199ca461
md"""
##
"""

# ╔═╡ 3573a709-37a5-4fec-9121-1f0a70a17910
Markdown.parse("
- For the floating leg, we know that its value will be par at the next reset date at ``t=0.25``.
- We also know that the first cash flow on the floating leg at ``t=0.25`` is locked in at the 3-month interest rate (when we executed the contract, i.e. prior to the interest rate change) 
``\$L(0.25) = \\frac{r_{0.25}}{4} \\times N = \\frac{$(rVec_2[1])\\%}{4} \\times $(roundmult(F_2,1e-2)) = $(roundmult(rVec_2[1]/400*F_2,1e-4))\$``

")

# ╔═╡ 1c309a37-0c41-4e29-bcc1-55f8cc9214aa
md"""
##
"""

# ╔═╡ 0d5a71d7-b3fa-493c-8f83-b8e8bdde6cf5
Markdown.parse("
- Thus, the value of the floating leg today is the present value of the first cash flow plus the present value of the par value.
``\$P_{\\textrm{Float}} = \\frac{N+L(0.25)}{\\left(1+\\frac{r_{0.25}}{4}\\right)^{4\\times 0.25}} = \\frac{$(roundmult(F_2,1e-2))+$(roundmult(rVec_2[1]/400*F_2,1e-4))}{\\left(1+\\frac{$(rVec_3[1])\\%}{4}\\right)^{4\\times 0.25}} = $(roundmult((F_2+rVec_2[1]/400*F_2)/(1+rVec_3[1]/400)^(4*0.25),1e-4))\$``
")

# ╔═╡ c2e9e9a9-6dd7-4f9c-8140-2d5976fcc8eb
md"""
##
"""

# ╔═╡ 67cdb61f-43d2-45c3-90db-f5a94beac805
Markdown.parse("
- Thus, the value of the floating leg is now ``P_{\\textrm{Float}}=$(roundmult((F_2+rVec_2[1]/400*F_2)/(1+rVec_3[1]/400)^(4*0.25),1e-2))`` and the value of the fixed leg is ``P_{\\textrm{Fixed}}=$(roundmult((rswap_2/4*F_2)*sum(DTVec_3)+F_2*DTVec_3[end],1e-4))``.
- Since we entered into the swap as the fixed rate payer, the interest rate swap now has a positive value to us.
``\$ P_{\\textrm{Swap}} = $(roundmult((F_2+rVec_2[1]/400*F_2)/(1+rVec_3[1]/400)^(4*0.25)-(((rswap_2/4*F_2)*sum(DTVec_3)+F_2*DTVec_3[end])),1e-2))\$``
- This is intuitive, since we are paying a fixed rate which was set when interest rates were lower than they are after the interest rate increase.
")

# ╔═╡ 7198c746-236b-42e3-a248-23e847c189d6
md"""
## Another Practice Problem
"""

# ╔═╡ f3653023-ac63-4b9d-8afa-7706db428df7
begin
 tVec_4 = [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0]
 rVec_4 = [4.05,4.10,4.25,4.37,4.47,4.57,4.65,4.72,4.80,4.87,4.94,5.01]	
 rVec_42 = [5.25,5.49,5.59,5.69,5.78,5.86,5.95,6.05,7.00,7.05,7.45,7.55]	
	
 pvAnn_4  = sum(1 ./ ( 1 .+ rVec_4./400).^(4 .* tVec_4))
 pvAnn_42 = sum(1 ./ ( 1 .+ rVec_42./400).^(4 .* tVec_4))
 F_4 = 100
 C_4 = F_4*(1-1/(1+rVec_4[end]/400)^(4*tVec_4[end]))/pvAnn_4
 C_42 = F_4*(1-1/(1+rVec_42[end]/400)^(4*tVec_4[end]))/pvAnn_42
 DTVec_4  = 1 ./ (1 .+ rVec_4/400).^(4 .* tVec_4)
 DTVec_42 = 1 ./ (1 .+ rVec_42/400).^(4 .* tVec_4)
 rswap_4 = 4*(1-DTVec_4[end])/(sum(DTVec_4))	
 rswap_42 = 4*(1-DTVec_42[end])/(sum(DTVec_42))	
 display("")	
end

# ╔═╡ c34395b0-c814-4134-9c1a-e2a6f7253a31
md"""
- Solve for the fixed interest rate swap rate $f$ of a three-year swap with a notional of \$ $(F_4) million. Assume that we enter the interst rate swap as the fixed rate payer.

Time to maturity $t$   | Spot rate $r(0,t)$
----------------------:|--------------------:
$(tVec_4[1]) | $(rVec_4[1])%
$(tVec_4[2])  | $(rVec_4[2])%
$(tVec_4[3]) | $(rVec_4[3])%
$(tVec_4[4])    | $(rVec_4[4])%
$(tVec_4[5]) | $(rVec_4[5])%
$(tVec_4[6])  | $(rVec_4[6])%
$(tVec_4[7]) | $(rVec_4[7])%
$(tVec_4[8])    | $(rVec_4[8])%
$(tVec_4[9]) | $(rVec_4[9])%
$(tVec_4[10]) | $(rVec_4[10])%
$(tVec_4[11]) | $(rVec_4[11])%
$(tVec_4[12]) | $(rVec_4[12])%
"""

# ╔═╡ 0e115290-e74b-4065-bf4e-57bcee7ce250
md"""
##
"""

# ╔═╡ 50abc53c-36ac-4e1d-aa33-4fc542cb2862
Markdown.parse("
- Let's get the discount factors first.

Time to maturity ``t``      |  Spot rate ``r``   | Discount Factor ``D(t)`` | Calculation
------:|-------:|-------------------------------:|----------------------:
$(tVec_4[1])   | $(rVec_4[1])%  | $(roundmult(DTVec_4[1],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_4[1])\\%/4 \\right)^{4 \\times $(tVec_4[1])}}\$``
$(tVec_4[2])    | $(rVec_4[2])% | $(roundmult(DTVec_4[2],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_4[2])\\%/4 \\right)^{4 \\times $(tVec_4[2])}}\$``
$(tVec_4[3])   | $(rVec_4[3])%  | $(roundmult(DTVec_4[3],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_4[3])\\%/4 \\right)^{4 \\times $(tVec_4[3])}}\$``
$(tVec_4[4])      | $(rVec_4[4])% | $(roundmult(DTVec_4[4],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[4])\\%/4 \\right)^{4 \\times $(tVec_4[4])}}\$`` 
$(tVec_4[5])      | $(rVec_4[5])% | $(roundmult(DTVec_4[5],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[5])\\%/4 \\right)^{4 \\times $(tVec_4[5])}}\$`` 
$(tVec_4[6])      | $(rVec_4[6])% | $(roundmult(DTVec_4[6],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[6])\\%/4 \\right)^{4 \\times $(tVec_4[6])}}\$`` 
$(tVec_4[7])      | $(rVec_4[7])% | $(roundmult(DTVec_4[7],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[7])\\%/4 \\right)^{4 \\times $(tVec_4[7])}}\$`` 
$(tVec_4[8])      | $(rVec_4[8])% | $(roundmult(DTVec_4[8],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[8])\\%/4 \\right)^{4 \\times $(tVec_4[8])}}\$`` 
$(tVec_4[9])      | $(rVec_4[9])% | $(roundmult(DTVec_4[9],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[9])\\%/4 \\right)^{4 \\times $(tVec_4[9])}}\$`` 
$(tVec_4[10])      | $(rVec_4[10])% | $(roundmult(DTVec_4[10],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[10])\\%/4 \\right)^{4 \\times $(tVec_4[10])}}\$`` 
$(tVec_4[11])      | $(rVec_4[11])% | $(roundmult(DTVec_4[11],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[11])\\%/4 \\right)^{4 \\times $(tVec_4[11])}}\$`` 
$(tVec_4[12])      | $(rVec_4[12])% | $(roundmult(DTVec_4[12],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_4[12])\\%/4 \\right)^{4 \\times $(tVec_4[12])}}\$`` 
")

# ╔═╡ aa629539-d96b-411a-91d1-d43932de869a
md"""
##
"""

# ╔═╡ 4aa4dbe3-b071-444f-ae18-0988d8937f60
Markdown.parse("
- Next, we use that the fair swap rate ``f`` of a ``T``-year interest rate swap (with quarterly cash flows) can be calculated using discount factors ``D(t)`` as

``\$f = 4\\times \\frac{1-D(T)}{D(0.25)+D(0.50)+D(0.75)+\\ldots+D(T)}\$``

- Thus, the fair rate ``f`` on the fixed leg of the ``$(tVec_4[end])``-year interest rate swap is
``\$f = 4\\times \\frac{1-D($(tVec_4[end]))}{D(0.25)+D(0.50)+\\ldots +D($(tVec_4[end]))}\$``
``\$f = 4\\times \\frac{1-$(roundmult(DTVec_4[end],1e-4))}{$(roundmult(DTVec_4[1],1e-4))+$(roundmult(DTVec_4[2],1e-4))+$(roundmult(DTVec_4[3],1e-4))+\\ldots + $(roundmult(DTVec_4[end],1e-4))}=$(roundmult(rswap_4*100,1e-4))\\%\$``
- The quarterly cash flows ``C`` on the fixed leg are
``\$C=N \\times \\frac{f}{4} = $(roundmult(F_4,1e-4)) \\times \\frac{$(roundmult(rswap_4*100,1e-4))\\%}{4} = $(roundmult(rswap_4/4*F_4,1e-4))\$``
")

# ╔═╡ fc4aa8e8-abf5-4d68-8865-c3ed42dd4fce
md"""
##
"""

# ╔═╡ 287764da-1a5d-4a3e-93ef-0b2216eaecc8
md"""
- Suppose now that one year passes and that the spot rates are now

Time to maturity $t$   | Spot rate $r(0,t)$
----------------------:|--------------------:
$(tVec_4[1]) | $(rVec_42[1])%
$(tVec_4[2])  | $(rVec_42[2])%
$(tVec_4[3]) | $(rVec_42[3])%
$(tVec_4[4])    | $(rVec_42[4])%
$(tVec_4[5]) | $(rVec_42[5])%
$(tVec_4[6])  | $(rVec_42[6])%
$(tVec_4[7]) | $(rVec_42[7])%
$(tVec_4[8])    | $(rVec_42[8])%
$(tVec_4[9]) | $(rVec_42[9])%
$(tVec_4[10]) | $(rVec_42[10])%
$(tVec_4[11]) | $(rVec_42[11])%
$(tVec_4[12]) | $(rVec_42[12])%

- Assume that the floating rate has just reset after the change in interest rates.
- What is the value of the interest rate swap now?
"""

# ╔═╡ b4eb9302-3ddf-4b46-a09d-2018748bed1f
md"""
##
"""

# ╔═╡ 5ada8541-9e34-4cec-9e66-a39e75d0e268
Markdown.parse("
- First, note that we are locked into an interest rate swap at a fixed rate ``f=$(roundmult(rswap_4*100,1e-4))``%. The swap has ``$(tVec_4[end-4])`` years to maturity.
- The cash flows on the fixed leg are ``C=$(roundmult(rswap_4/4*F_4,1e-4))`` million.
- Thus, the value of the fixed leg is now

``\$P_{\\textrm{Fixed}}=C\\times D(0.25) + C\\times D(0.5) + C\\times D(0.75) +\\ldots + (C+N)\\times D(2.0)\$``
``\$P_{\\textrm{Fixed}}=$(roundmult(rswap_4/4*F_4,1e-2))\\times $(roundmult(DTVec_42[1],1e-4)) + $(roundmult(rswap_4/4*F_4,1e-2))\\times $(roundmult(DTVec_42[2],1e-4)) + \\ldots + ($(roundmult(rswap_4/4*F_4,1e-2))+$(roundmult(F_4,1e-2)))\\times $(roundmult(DTVec_42[end-4],1e-4)) = $(roundmult((rswap_4/4*F_4)*sum(DTVec_42[1:end-4])+F_4*DTVec_42[end-4],1e-4))\$``
")

# ╔═╡ ce189ed7-ba22-4738-bc64-85a7255c6cd6
md"""
##
"""

# ╔═╡ e85993df-cf07-4480-9e53-8210ecbcf9f9
Markdown.parse("
- Since the floating rate has just reset after the change in interest rates, the value of the floating leg is par.
``\$P_{\\textrm{Float}} = N = $(F_4)\$``
")

# ╔═╡ a1cd9ae9-27e6-4124-b3af-369d6a51692a
md"""
##
"""

# ╔═╡ 99b79622-3427-4d29-a0e0-bbe0c22cbb35
Markdown.parse("
- Thus, the value of the interst rate swap to us as the fixed rate payer is now
``\$P_{\\textrm{Swap}} = P_{\\textrm{Float}} - P_{\\textrm{Fixed}} = $(F_4) - $(roundmult((rswap_4/4*F_4)*sum(DTVec_42[1:end-4])+F_4*DTVec_42[end-4],1e-4)) = $(roundmult(F_4-((rswap_4/4*F_4)*sum(DTVec_42[1:end-4])+F_4*DTVec_42[end-4]),1e-4))\$``
")

# ╔═╡ 8e7f01e8-66d8-4a61-950c-1d6f97336e91
md"""
# Hedging with Interest Rate Swaps
"""

# ╔═╡ 2c82023c-9aff-4a41-9dc9-47bf2c9b15b1
md"""
- Many firms use interest rate swaps to hedge exposures to interest rates (see e.g. GE).
- How can we use interest rate swaps to hedge interest rate risk?
"""

# ╔═╡ a4001eb2-32ad-46a1-9002-324ebf71bd25
md"""
##
"""

# ╔═╡ f046ae5f-2b8b-42fc-8d70-133c4e9c725c
md"""
- Let’s think about a party that is paying fixed and receiving floating.
- This is equivalent to being long a floating rate bond and short a fixed rate bond.
- If interest rates increase:
  - The floating bond is almost unchanged in value. (It declines slightly in value.)
  - The fixed rate bond declines in value.
- If we pay fixed and receive floating, our overall change in value is positive.
  - Note that this was the case in the previous example.
"""

# ╔═╡ c271f654-8f2a-4720-8611-63bf946d4b73
md"""
##
"""

# ╔═╡ 8d80bca6-44f5-431e-b892-7bb47074379c
md"""
- This means that if we own a portfolio of vanilla fixed coupon bonds, the value of our portfolio declines if interest rates increase.
- Fixed-for-floating interest rate swaps increase in value as interest rates increase.
- Thus, we can decrease our exposure to interest rates by entering into an interest rate swap, paying fixed and receiving floating.
"""

# ╔═╡ b09b6bd3-7b2a-4646-9996-4cfe55c3acfc
md"""
# Modified Duration of an Interest Rate Swap
"""

# ╔═╡ d77ed377-9912-4535-9f27-a2506ce3ad2a
begin
  tVec_5 = [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0]
  rVec_5 = [3.0,3.2,3.3,3.5,3.6,3.6,3.7,3.8,4,4.1,4.2,4.3]	
  rVecPlus_5 = [3.0,3.2,3.3,3.5,3.6,3.6,3.7,3.8,4,4.1,4.2,4.3] .+ 0.1	
  rVecMinus_5 = [3.0,3.2,3.3,3.5,3.6,3.6,3.7,3.8,4,4.1,4.2,4.3] .- 0.1	
  pvAnn_5  = sum(1 ./ ( 1 .+ rVec_5./400).^(4 .* tVec_5))
  F_5 = 100
  C_5 = F_5*(1-1/(1+rVec_5[end]/400)^(4*tVec_5[end]))/pvAnn_5
  DTVec_5  = 1 ./ (1 .+ rVec_5/400).^(4 .* tVec_5)
  DTVecPlus_5  = 1 ./ (1 .+ rVecPlus_5/400).^(4 .* tVec_5)
  DTVecMinus_5  = 1 ./ (1 .+ rVecMinus_5/400).^(4 .* tVec_5)
  rswap_5 = 4*(1-DTVec_5[end])/(sum(DTVec_5))
  PfixPlus = sum( F_5 .* rswap_5 ./4 .* ones(length(tVec_5)) .* DTVecPlus_5) + F_5 * DTVecPlus_5[end]
  PfixMinus = sum( F_5 .* rswap_5 ./4 .* ones(length(tVec_5)) .* DTVecMinus_5) + F_5 * DTVecMinus_5[end]
  display("")	
end

# ╔═╡ 7f55f4c8-63da-4cbd-938f-349914e432df
md"""
- Our goal is to compute the duration of a three-year swap with a notional of \$ $(F_4) million.
- Assume that spot rates are as follow (quarterly compounded).

Time to maturity $t$   | Spot rate $r(t)$
----------------------:|--------------------:
$(tVec_5[1]) | $(rVec_5[1])%
$(tVec_5[2])  | $(rVec_5[2])%
$(tVec_5[3]) | $(rVec_5[3])%
$(tVec_5[4])    | $(rVec_5[4])%
$(tVec_5[5]) | $(rVec_5[5])%
$(tVec_5[6])  | $(rVec_5[6])%
$(tVec_5[7]) | $(rVec_5[7])%
$(tVec_5[8])    | $(rVec_5[8])%
$(tVec_5[9]) | $(rVec_5[9])%
$(tVec_5[10]) | $(rVec_5[10])%
$(tVec_5[11]) | $(rVec_5[11])%
$(tVec_5[12]) | $(rVec_5[12])%
"""

# ╔═╡ adcab120-9262-4c24-931d-ce089414a45d
md"""
##
"""

# ╔═╡ a7695d30-00cd-4000-8992-1c93e99506ce
Markdown.parse("
- To simplify the calculations, let's get the discount factors.

Time to maturity ``t``      |  Spot rate ``r``   | Discount Factor ``D(t)`` | Calculation
------:|-------:|-------------------------------:|----------------------:
$(tVec_5[1])   | $(rVec_5[1])%  | $(roundmult(DTVec_5[1],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_5[1])\\%/4 \\right)^{4 \\times $(tVec_5[1])}}\$``
$(tVec_5[2])    | $(rVec_5[2])% | $(roundmult(DTVec_5[2],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_5[2])\\%/4 \\right)^{4 \\times $(tVec_5[2])}}\$``
$(tVec_5[3])   | $(rVec_5[3])%  | $(roundmult(DTVec_5[3],1e-6)) | ``\$\\frac{1}{\\left(1+$(rVec_5[3])\\%/4 \\right)^{4 \\times $(tVec_5[3])}}\$``
$(tVec_5[4])      | $(rVec_5[4])% | $(roundmult(DTVec_5[4],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[4])\\%/4 \\right)^{4 \\times $(tVec_5[4])}}\$`` 
$(tVec_5[5])      | $(rVec_5[5])% | $(roundmult(DTVec_5[5],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[5])\\%/4 \\right)^{4 \\times $(tVec_5[5])}}\$`` 
$(tVec_5[6])      | $(rVec_5[6])% | $(roundmult(DTVec_5[6],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[6])\\%/4 \\right)^{4 \\times $(tVec_5[6])}}\$`` 
$(tVec_5[7])      | $(rVec_5[7])% | $(roundmult(DTVec_5[7],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[7])\\%/4 \\right)^{4 \\times $(tVec_5[7])}}\$`` 
$(tVec_5[8])      | $(rVec_5[8])% | $(roundmult(DTVec_5[8],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[8])\\%/4 \\right)^{4 \\times $(tVec_5[8])}}\$`` 
$(tVec_5[9])      | $(rVec_5[9])% | $(roundmult(DTVec_5[9],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[9])\\%/4 \\right)^{4 \\times $(tVec_5[9])}}\$`` 
$(tVec_5[10])      | $(rVec_5[10])% | $(roundmult(DTVec_5[10],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[10])\\%/4 \\right)^{4 \\times $(tVec_5[10])}}\$`` 
$(tVec_5[11])      | $(rVec_5[11])% | $(roundmult(DTVec_5[11],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[11])\\%/4 \\right)^{4 \\times $(tVec_5[11])}}\$`` 
$(tVec_5[12])      | $(rVec_5[12])% | $(roundmult(DTVec_5[12],1e-6))| ``\$\\frac{1}{\\left(1+$(rVec_5[12])\\%/4 \\right)^{4 \\times $(tVec_5[12])}}\$`` 
")

# ╔═╡ 7d1feb9a-31c3-4708-8d40-38fb3136344a
md"""
##
"""

# ╔═╡ 959d48f7-fd7d-4342-8693-e3e73739a75b
Markdown.parse("
- First, let's solve for the fixed interest rate swap rate ``f``. Assume that we enter the interst rate swap as the fixed rate payer.
- We use that the fair swap rate ``f`` of a ``T``-year interest rate swap (with quarterly cash flows) can be calculated using discount factors ``D(t)`` as

``\$f = 4\\times \\frac{1-D(T)}{D(0.25)+D(0.50)+D(0.75)+\\ldots+D(T)}\$``


")

# ╔═╡ b8173564-fffd-4a10-b5c4-06caa139df87
md"""
##
"""

# ╔═╡ 76482358-54c6-4685-9b47-a7a02bb67975
Markdown.parse("
- Thus, the fair rate ``f`` on the fixed leg of the ``$(tVec_4[end])``-year interest rate swap is
``\$f = 4\\times \\frac{1-D($(tVec_5[end]))}{D(0.25)+D(0.50)+\\ldots +D($(tVec_5[end]))}\$``
``\$f = 4\\times \\frac{1-$(roundmult(DTVec_5[end],1e-4))}{$(roundmult(DTVec_5[1],1e-4))+$(roundmult(DTVec_5[2],1e-4))+$(roundmult(DTVec_5[3],1e-4))+\\ldots + $(roundmult(DTVec_5[end],1e-4))}=$(roundmult(rswap_5*100,1e-4))\\%\$``
- The quarterly cash flows ``C`` on the fixed leg are
``\$C=N \\times \\frac{f}{4} = $(roundmult(F_5,1e-4)) \\times \\frac{$(roundmult(rswap_5*100,1e-4))\\%}{4} = $(roundmult(rswap_5/4*F_4,1e-4))\$``
")

# ╔═╡ 3ccd290a-df66-4a36-b488-3ab7d588668c
md"""
##
"""

# ╔═╡ 4ed852d4-6de1-4ae7-b3f7-6934fc261b18
Markdown.parse("
- Note that as the fixed rate payer, we are essentially short a bond with quarterly coupon cash flows of ``C``, and we are long one floating rate bond with face value equal to the notional ``N`` of the interest rate swap.
- Moreover, since the interest rate swap is faily valued at inception, the value of the floating leg is equal to the fixed leg. Thus, the market values are both equal to par.
- We can illustrate this using a balance sheet
Assets (Long position)     | Liabilities (Shot position)
--------------------------:|----------------------:
Floating rate note:  \$ ``$(F_5)``    | 3-year bond, coupon rate ``f``: \$ ``$(F_5)``
")

# ╔═╡ 910a7054-a6e9-4e08-8e8a-1194eaa5aa02
md"""
##
"""

# ╔═╡ cc927e4d-2814-41c1-99bc-1ed344caaac2
Markdown.parse("
- Thus, an interest rate swap is essentially a portfolio of an FRN and fixed-rate bond.
- We know that the modified duration of a portfolio is the value-weighted average of the bonds in the portfolio.
- First, let's determine the modified duration of the FRN.
")


# ╔═╡ 7c02cc51-4284-4743-8ad4-bae13f9414b2
md"""
##
"""

# ╔═╡ 5c7b92c8-4190-402e-855a-7f48264fb413
Markdown.parse("
- Recall that the modified duration is given by
``\$ MD = - \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{2\\times \\Delta y} \\times \\frac{1}{P(y)}\$``
- For the floating leg of the swap, we again use that its value will be par on the next reset and that the next floating coupon cash flow is already set today at ``\$ L(0.25)=\\frac{r_{0.25}}{4}\\times N = \\frac{$(roundmult(rVec_5[1],1e-4))\\%}{4} \\times $(F_5) = $(roundmult(rVec_5[1]/400*F_5,1e-4)) \$``

")

# ╔═╡ b94b7cca-10d3-40c0-987e-5b9a8a46fba3
md"""
##
"""

# ╔═╡ e9b1c327-3867-4c0e-8d6f-85ae2c59d8eb
Markdown.parse("
- Hence,
``\$ P_{\\textrm{Float}}(y) = N = $(F_5)\$``

``\$ P_{\\textrm{Float}}(y+\\Delta y) = \\frac{N + L(0.25) }{\\left(1+\\frac{$(rVec_5[1])\\%+0.1\\%}{4} \\right)} = \\frac{$(F_5) + $(roundmult(rVec_5[1]/400*F_5,1e-4))}{\\left(1+\\frac{$(rVec_5[1])\\%+0.1\\%}{4} \\right)}=$(roundmult((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]+0.1)/400)^(4*0.25),1e-4))\$``

``\$ P_{\\textrm{Float}}(y-\\Delta y) = \\frac{N + L(0.25) }{\\left(1+\\frac{$(rVec_5[1])\\%-0.1\\%}{4} \\right)} = \\frac{$(F_5) + $(roundmult(rVec_5[1]/400*F_5,1e-4))}{\\left(1+\\frac{$(rVec_5[1])\\%-0.1\\%}{4} \\right)}=$(roundmult((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]-0.1)/400)^(4*0.25),1e-4))\$``

``\$ MD_{\\textrm{Float}} = -\\frac{$(roundmult((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]+0.1)/400)^(4*0.25),1e-4))-$(roundmult((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]-0.1)/400)^(4*0.25),1e-4))}{2 \\times 0.001} \\times \\frac{1}{$(F_5)}=$(roundmult( -( ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]+0.1)/400)^(4*0.25)) - ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]-0.1)/400)^(4*0.25)))/(2*.001) * 1/F_5,1e-4))\$``
")

# ╔═╡ 5ac58cac-9dc6-40ca-8524-ca05768b062e
md"""
##
"""

# ╔═╡ fea6cd9b-9bbe-47ae-abb5-1729eec449b7
Markdown.parse("
- Next, let's determine the modified duration of the fixed leg of the swap.
- Recall that the fixed leg is similar to a fixed-rate coupon rate bond with quarterly coupon cash flows at an annual rate of ``f=$(roundmult(rswap_5*100,1e-4))\\%``.
  - We have already calculated ``C=N \\times \\frac{f}{4} = $(roundmult(F_5,1e-4)) \\times \\frac{$(roundmult(rswap_5*100,1e-4))\\%}{4} = $(roundmult(rswap_5/4*F_4,1e-4))``

")

# ╔═╡ d7923836-03cd-478f-be58-99b99af2717e
md"""
##
"""

# ╔═╡ 8c600e1c-50da-424b-b194-1bc2d9427ecc
Markdown.parse("
- The current value of the fixed leg at inception of the interest rate swap is par.

``\$ P_{\\textrm{Fixed}}(y) = N = $(F_5)\$``

``\$ P_{\\textrm{Fixed}}(y + \\Delta y) = \\frac{C}{\\left(1+\\frac{r_{0.25}+0.1\\%}{4}\\right)^{4\\times 0.25}} + \\ldots + \\frac{C+N}{\\left(1+\\frac{r_{3.0}+0.1\\%}{4}\\right)^{4\\times 3.0}} = $(roundmult(PfixPlus,1e-4))\$``

``\$ P_{\\textrm{Fixed}}(y - \\Delta y) = \\frac{C}{\\left(1+\\frac{r_{0.25}+0.1\\%}{4}\\right)^{4\\times 0.25}} + \\ldots + \\frac{C+N}{\\left(1+\\frac{r_{3.0}+0.1\\%}{4}\\right)^{4\\times 3.0}} = $(roundmult(PfixMinus,1e-4))\$``

``\$MD_{\\textrm{Fixed}} = -\\frac{ $(roundmult(PfixPlus,1e-4)) - $(roundmult(PfixMinus,1e-4)) }{2\\times 0.001} \\times \\frac{1}{$(F_5)} = $(roundmult( -(PfixPlus-PfixMinus)/(2*0.001) * 1/F_5,1e-4))\$``
")

# ╔═╡ 8a4e8006-67b3-4bdc-8bc6-5dde34af0bed
md"""
##
"""

# ╔═╡ 9486cc7a-acef-4d66-9b8a-dc6da9ddf94e
Markdown.parse("
- Knowing the modified durations of the fixed leg and the floating leg of the swap, we can now calculate the modified duration ``MD_{\\textrm{Swap}}``.

``\$MD_{\\textrm{Swap}} = MD_{\\textrm{Float}} - MD_{\\textrm{Fixed}} = $(roundmult( -( ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]+0.1)/400)^(4*0.25)) - ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]-0.1)/400)^(4*0.25)))/(2*.001) * 1/F_5,1e-4)) - $(roundmult( -(PfixPlus-PfixMinus)/(2*0.001) * 1/F_5,1e-4)) = $(roundmult(1*(-( ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]+0.1)/400)^(4*0.25)) - ((F_5+rVec_5[1]/400*F_5)/(1+(rVec_5[1]-0.1)/400)^(4*0.25)))/(2*.001) * 1/F_5)-1*(-(PfixPlus-PfixMinus)/(2*0.001) * 1/F_5),1e-4))\$`` 
")

# ╔═╡ b0a96340-f28f-403e-995e-cf4853e6c9f8
md"""
##
"""

# ╔═╡ 13ecc6b8-ffd4-4dba-8bef-6e51aff98642
Markdown.parse("
- Let's now use the interest rate swap to hedge a position in a three-year bond with coupon rate ``c=6``% (paid quarterly). The face value of the bond is \$ 100.
- First, we need the modified duration ``MD_{\\textrm{Bond}}`` of the bond.
``\$ P_{\\textrm{Bond}}(y) = \\frac{1.5}{\\left(1+\\frac{0.03}{4}\\right)^{4\\times 0.25}} + \\frac{1.5}{\\left(1+\\frac{0.032}{4}\\right)^{4\\times 0.5}} + \\ldots + \\frac{1.5+100}{\\left(1+\\frac{0.043}{4}\\right)^{4\\times 3}} = 104.8707\$`` 

``\$ P_{\\textrm{Bond}}(y+\\Delta y) = \\frac{1.5}{\\left(1+\\frac{0.03+0.001}{4}\\right)^{4\\times 0.25}} + \\frac{1.5}{\\left(1+\\frac{0.032+0.001}{4}\\right)^{4\\times 0.5}} + \\ldots + \\frac{1.5+100}{\\left(1+\\frac{0.043+0.001}{4}\\right)^{4\\times 3}} = 104.5834\$`` 

``\$ P_{\\textrm{Bond}}(y-\\Delta y) = \\frac{1.5}{\\left(1+\\frac{0.03-0.001}{4}\\right)^{4\\times 0.25}} + \\frac{1.5}{\\left(1+\\frac{0.032-0.001}{4}\\right)^{4\\times 0.5}} + \\ldots + \\frac{1.5+100}{\\left(1+\\frac{0.043-0.001}{4}\\right)^{4\\times 3}} = 105.1589\$`` 

``\$ MD_{\\textrm{Bond}} = - \\frac{104.5834 − 105.1589}{2\\times 0.001} \\times \\frac{1}{104.8707}=2.7438\$``
")

# ╔═╡ b82e97e7-96f3-4782-8ad0-c0aa5f85f89f
md"""
##
"""

# ╔═╡ 9de1d64f-6f83-4856-9240-363a76848b48
Markdown.parse("
- To hedge the bond using the interest rate swap, we require that change in the market value of the bond is offset by the change in value of the interest rate swap.
- Suppose the interst rate swap has notional ``N=x``.
- Thus,
``\$ P_{\\textrm{Bond}} \\times MD_{\\textrm{Bond}} \\times \\Delta y + x \\times MD_{\\textrm{Swap}} \\times \\Delta y \\stackrel{!}{=} 0\$``
- Hence, the notional ``N`` of the swap must be equal to

``\$x = -\\frac{P_{\\textrm{Bond}} \\times MD_{\\textrm{Bond}}}{MD_{\\textrm{Swap}}} = - \\frac{104.8707 \\times 2.7438}{-2.5525} = $(roundmult(104.8707*2.7438/2.5525,1e-4))\$``

")

# ╔═╡ 8329ec8f-9df0-41fb-bccf-5bb6b1800b67
md"""
##
"""

# ╔═╡ 9a83ce8e-10a1-43da-b712-85a0a1603d95
md"""
- Finally, let’s check how well the hedge works. 
- Suppose now that all spot rates increase by 0.5 percent.

Time to maturity $t$   | Spot rate $r(t)$
----------------------:|--------------------:
$(tVec_5[1]) | $(rVec_5[1]+0.5)%
$(tVec_5[2])  | $(rVec_5[2]+0.5)%
$(tVec_5[3]) | $(rVec_5[3]+0.5)%
$(tVec_5[4])    | $(rVec_5[4]+0.5)%
$(tVec_5[5]) | $(rVec_5[5]+0.5)%
$(tVec_5[6])  | $(rVec_5[6]+0.5)%
$(tVec_5[7]) | $(rVec_5[7]+0.5)%
$(tVec_5[8])    | $(rVec_5[8]+0.5)%
$(tVec_5[9]) | $(rVec_5[9]+0.5)%
$(tVec_5[10]) | $(rVec_5[10]+0.5)%
$(tVec_5[11]) | $(rVec_5[11]+0.5)%
$(tVec_5[12]) | $(rVec_5[12]+0.5)%
"""

# ╔═╡ 29ec0ce6-cc3a-4700-89bf-fe267e0e4106
md"""
##
"""

# ╔═╡ c101b031-ed89-414b-b5bb-ceda4b32cb30
Markdown.parse("
- The value of the bond is now
``\$ P = \\frac{1.5}{\\left(1+\\frac{0.035}{4} \\right)^{4\\times 0.25}} + \\ldots + \\frac{1.5+100}{\\left(1+\\frac{0.048}{4} \\right)^{4\\times 3}} = 103.4432\$``
- Before the change in interest rates, the bond price was ``104.8707``. Thus the change in value is
``\$\\Delta P_{\\textrm{Bond}} = 103.4432 - 104.8707 = -1.4275\$``
")

# ╔═╡ 0e70982c-bd4d-4deb-a7ed-1ce10e1e6311
md"""
##
"""

# ╔═╡ 2ff7733c-4e14-498c-8fcf-b75987a49df1
Markdown.parse("
- The **floating leg** of the interest rate swap changes as follows.
  - Note that we entered into \$ 112.73 in notional of the interest rate swap, *not* 100. 
  - To simplify the calculation, we will start with a \$ 100 notional. Then, we will make an adjustment. Basically, we use that a \$ 112.73 notional are 1.1273 units of \$ 100 notional.

``\$ \\textrm{Price per 100 notional} = \\frac{100+100\\times\\frac{0.03}{4}}{1+\\frac{0.035}{4}}=99.8761\$``

``\$ \\textrm{Price per 112.73 notional} = \\frac{112.73}{100}\\times \\textrm{Price per 100 notional} = 112.73\$``

- Recall that the previous market value of the floating leg was \$ 112.73.
- Thus, the change in value of the floating leg in the interest rate swap is
``\$ \\Delta P_{\\textrm{Float}}=112.59 − 112.73 = −0.1397\$``
")

# ╔═╡ 45134982-845c-4340-8149-e111cf72a7a8
md"""
##
"""

# ╔═╡ 98d0c2c2-4d6b-499e-a84d-871e35f6ab98
Markdown.parse("
- The **fixed leg** of the interest rate swap changes as follows.
  - Note that we entered into \$ 112.73 in notional of the interest rate swap, *not* 100. 
  - To simplify the calculation, we will start with a \$ 100 notional. Then, we will make an adjustment. Basically, we use that a \$ 112.73 notional are 1.1273 units of \$ 100 notional.

``\$ \\textrm{Price per 100 notional} = \\frac{1.06802}{1+\\frac{0.035}{4}} + \\ldots \\frac{1.06802+100}{\\left(1+\\frac{0.048}{4}\\right)^12} =99.61068\$``

``\$ \\textrm{Price per 112.73 notional} = \\frac{112.73}{100}\\times \\textrm{Price per 100 notional} = 111.1638\$``

- The previous value of the fixed leg was \$ ``112.73``.
- Thus, the change in value of the fixed leg is
``\$ \\Delta P_{\\textrm{Fixed}}=111.1638-112.73=-1.566\$``
")

# ╔═╡ 935a06da-0926-46f5-a4ab-33344d0b0be8
md"""
##
"""

# ╔═╡ 6b71002c-49fa-4d6a-900d-fd49ed5b7d1d
Markdown.parse("
- The total change in the swap and the bond is
``\$ (-1.4275 - 0.1397) - (-1.566) = $(roundmult((-1.4275 - 0.1397) - (-1.566),1e-4))\$``
- We can compare this to the change in the bond price without the interest rate swap hedge.
``\$\\Delta P_{\\textrm{Bond}} = -1.4275\$``
- Thus, by using an interest rate swap, we are able to reduce the change in the value of the bond when interest rates change.
")

# ╔═╡ 53c77ef1-899d-47c8-8a30-ea38380d1614
md"""
# Wrap-Up
"""

# ╔═╡ 670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
begin
	html"""
	<fieldset>      
        <legend>Goals for today</legend>      
		<br>
<input type="checkbox" value="" checked>Understanding what interest rate swaps and floating rate bonds are.<br><br>
<input type="checkbox" value="" checked>Calculating the fair fixed rate in an interest rate swap contract.<br><br>
<input type="checkbox" value="" checked>Calculating the price and modified duration of a floating rate bond.<br><br>
<input type="checkbox" value="" checked>Relating interest rate swaps, floating rate bonds, and fixed coupon bonds.<br><br>
<input type="checkbox" value="" checked>Calculating the value of an interest rate swap position after inception of the contract.<br><br>
<input type="checkbox" value="" checked>Using interest rate swaps to hedge interest rate exposure.<br><br>
</fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
# Reading
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 29
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
Luxor = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.2.2"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Luxor = "~2.17.0"
Plots = "~1.23.6"
PlutoUI = "~0.7.20"
PrettyTables = "~1.2.3"
XLSX = "~0.7.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

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

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

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
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

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
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

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

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "618835ab81e4a40acf215c98768978d82abc5d97"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.16"

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
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

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

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

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
git-tree-sha1 = "19cb49649f8c41de7fea32d089d37de917b553da"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.0.1"

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

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

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

[[Librsvg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pango_jll", "Pkg", "gdk_pixbuf_jll"]
git-tree-sha1 = "25d5e6b4eb3558613ace1c67d6a871420bfca527"
uuid = "925c91fb-5dd6-59dd-8e8c-345e74382d89"
version = "2.52.4+0"

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

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Luxor]]
deps = ["Base64", "Cairo", "Colors", "Dates", "FFMPEG", "FileIO", "Juno", "Random", "Rsvg"]
git-tree-sha1 = "1bd725204a6ab2301d4757b50d7062e89cfe18fe"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "2.17.0"

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

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

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

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "0d185e8c33401084cab546a756b387b15f76720c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.6"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "1e0cb51e0ccef0afc01aab41dc51a3e7f781e8cb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.20"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

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
git-tree-sha1 = "a4425fe1cde746e278fa895cc69e3113cb2614f6"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.0"

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

[[Rsvg]]
deps = ["Cairo", "Glib_jll", "Librsvg_jll"]
git-tree-sha1 = "3d3dc66eb46568fb3a5259034bfc752a0eb0c686"
uuid = "c4c386cf-5103-5370-be45-f3a111cca3b8"
version = "1.0.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "f45b34656397a1f6e729901dc9ef679610bd12b5"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.8"

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
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

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

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

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

[[gdk_pixbuf_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Xorg_libX11_jll", "libpng_jll"]
git-tree-sha1 = "c23323cd30d60941f8c68419a70905d9bdd92808"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.42.6+1"

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
# ╟─b9895f07-d73d-4447-ba4a-e5753e4e9f9d
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─733bbadf-a3ae-46d7-b9fb-6bb6526d74ce
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─d1b0ba85-b06b-4f01-af36-4c6f61e72607
# ╟─b8f54d24-cd72-439c-830d-d536a9e581f8
# ╟─d8af9752-110d-40d8-be95-7dde0ce917e5
# ╟─8de4a308-e5c0-45f0-b4fe-bc56ccbcf361
# ╟─7c8258d1-2b18-49ff-9c6d-beaf815d461f
# ╟─643ebf9c-707f-4649-b594-5fe63acf32fc
# ╟─e9d67d83-40a0-4241-8596-7fa40c1b5260
# ╟─85410abd-c2e3-4a17-840a-59601a76aba9
# ╟─796675e8-3235-4228-941b-fc1c72f43181
# ╟─7e09e75f-c2e5-4478-96df-b92906802869
# ╟─489c3e6a-8917-4fc1-bb67-8c368544b1e9
# ╟─e3fc4e42-c597-41bf-bf87-62e79e9f5791
# ╟─48cba890-b045-4358-b248-95249e1599ea
# ╟─5a61c0ff-e94b-4f1f-8bc4-e89738008fab
# ╟─85ffe526-f696-44bd-b5a0-d0d0816677af
# ╟─92686a88-a6ba-4ebe-9f01-46f2338c29db
# ╟─d9e3065d-a753-4f7a-ba3f-6aedc354e51d
# ╟─c8535a6c-fb32-42ca-b820-2cd6f07355c1
# ╟─8d33b72b-a217-46b2-806d-a9ff50986ea0
# ╟─16c5d14e-fab0-43a4-8d63-7d29fdf60163
# ╟─1bca6e3d-7333-4a16-b230-9c38d8d3d6a5
# ╟─0c3cfb7c-3d36-4ad7-9bf9-7c8f4eaa5d89
# ╟─40723f3e-c3ac-404f-81d2-5ef6b88327c0
# ╟─2d22fed6-c2e5-4ce0-99a1-d82ffa2b822e
# ╟─da277a3f-6778-4f14-89c4-a3b9c93a9fe1
# ╟─bc055004-1bd9-43b6-bb4f-82c9e71fca29
# ╟─bba1c7bd-3761-49b0-afd7-95c512dbb930
# ╟─474051a3-76e3-43f0-b3fd-f988a12f081e
# ╟─13bf94c0-b4d8-4fa4-82ad-6b8f4f5b2e69
# ╟─fb1342f6-85d0-4968-a60b-48a91479dc4c
# ╟─fe8c6909-eed7-4c50-8581-1b313f559615
# ╟─4b0cf5c1-aa94-4e5e-82f3-a328759f08e4
# ╟─2cc15fab-e9f6-4867-a51c-898c0b3f69da
# ╟─921cb531-e0d5-42ed-9ff5-db6d2882c115
# ╟─333e5ecc-7cff-4fe0-9e70-e810fcb82a93
# ╟─a731528c-1252-449b-951e-3cfb44d7d8f2
# ╟─fed756b8-8cc7-4225-aa62-28d62905d701
# ╟─b4612e94-58fd-4483-9cab-694520b0d0ca
# ╟─9d9ea7a2-af76-4e67-afad-5950f062806b
# ╟─45e2bef5-33a7-4b0e-ae13-9ff77e1e605b
# ╟─b87fdef9-b66c-48d3-b09d-37bd5adf3b72
# ╟─ce6c871f-63ea-4566-a42f-23a83b1f9ea8
# ╟─02ad0994-40c8-4d00-9abd-80b027e50636
# ╟─fcaa3ffb-102d-4e60-a0f9-b216343e368d
# ╟─a525b6bb-3d21-40f7-b2fc-d09fc7bb8952
# ╟─e666b292-9df8-4230-86e3-4137459bab0c
# ╟─da851641-f6c8-4e29-8e8f-36cab8b6e81d
# ╟─860219f3-e654-49e8-80d2-d41270e74ac0
# ╟─d7352f66-0ae8-4aa3-b9c0-b7002a820a26
# ╟─ef3cffd5-2161-41f1-a695-a92dc5ec2c02
# ╟─adb60bdb-5c04-454b-8ca7-fc6563f9fb70
# ╟─c9afd2f8-e6de-4350-a3e6-a92d435a5c4b
# ╟─1a2bdfb7-6772-4240-8b2a-8d8cdca69d75
# ╟─544fbaa3-c44e-4313-9d4d-c85c313740a4
# ╟─7e08d13b-75e3-495e-a562-f1deddb04333
# ╟─b1e22280-26b3-43a8-bbfa-c0e43adc8dbf
# ╟─d769a15c-4a0d-4136-871c-5418718b785a
# ╟─f4711422-f99c-4458-a780-673db01791ca
# ╟─dc64e11a-683b-4e53-9e35-8168919c0ab7
# ╟─4221e262-def1-45fd-a680-0c99014c34ca
# ╟─e71e0f8b-dbb1-413a-bb95-77c7bf4f5938
# ╟─c636290f-1745-49f1-a8fa-fbc32394e198
# ╟─ac65ead2-7393-4bd2-bae9-5916f45d29a4
# ╟─6b02f982-f281-4667-8d36-b40175c5821d
# ╟─49c5f161-57e7-4996-9a6a-75c3c20cb405
# ╟─3efe7640-b582-4d21-a9bb-15ef90968d19
# ╟─a8eb8f9f-0a2c-4182-b154-e8774411b1da
# ╟─eb10aabc-6fe0-4780-b693-1e8661897559
# ╟─581532bb-c94e-40e2-9225-6cdc3b104bf9
# ╟─38050bcf-2d8a-4449-89e9-2bb3b1c9f2ff
# ╟─cd2c4d02-3ef6-484f-9513-3f7bd3d950b5
# ╟─951fef4c-97e4-46b7-aea3-61d893ad45b7
# ╟─0126f9d5-4c80-422c-9a9f-c8a5cefd4caf
# ╟─eb56521d-7716-4884-9849-3f2737d3b5b3
# ╟─548c7fc8-268d-41b9-a68a-344a939bc3f1
# ╟─ecf7e394-ee00-48a2-9f63-52e9320dcafb
# ╟─4f450508-1b62-460a-b5b8-ea75dae43b2e
# ╟─2a34d810-72df-4c5a-8362-891e4cf683e8
# ╟─16a369db-1212-4b9e-ba36-a14c468f2d06
# ╟─e63a4351-ff12-4b8a-a56f-48ab529bb71c
# ╟─76db86f2-a742-4fb8-b9db-15a3e37d130a
# ╟─656ac3da-be2f-46b8-9315-5eee010df3d7
# ╟─5feda40a-449e-4d75-89e5-d0a7d9897dd3
# ╟─e6b11140-f56c-420d-9854-1d23b0747549
# ╟─6ea82348-17f4-4821-85e6-4159d23be0cf
# ╟─fc2b1421-21fe-4379-a920-7121cabc9f56
# ╟─7c589329-a544-4dd8-ac2f-2167e76228bd
# ╟─347f6c88-1884-4102-b405-400c38e484d9
# ╟─2cbd81a0-6a6f-4fab-9cd6-4a41497ca8ae
# ╟─bab657f8-4984-4cdd-93c7-b4ed90f2f86d
# ╟─a3c079f6-2e0a-427c-a943-5b9ff2986bda
# ╟─9158d289-811b-459b-853c-e0fe96894750
# ╟─a1bad7a1-bf87-4372-a07c-72a5802cbf7e
# ╟─cf3b892d-a0bc-4acf-b191-79ce97d77f59
# ╟─8be141ab-1c8a-412c-8b80-6954f118e633
# ╟─8f350713-f1d7-4b0c-8036-d6b70186de0e
# ╟─91ccf353-fff5-4eb1-a0c3-99f45f024e35
# ╟─795d443d-685f-48cc-b489-be45774b7c8a
# ╟─1464e93f-4c7c-46ee-8902-eb7a2c3e9eb9
# ╟─dfd3169d-2fd4-4c44-846b-72fbb66df4a0
# ╟─fc6dfca0-a94f-4545-abb4-ea04976d250b
# ╟─ebd8cf3b-ff6f-45b1-b26a-11ec231473da
# ╟─59d69a62-217e-4ac2-9052-40cc9031c796
# ╟─8f1a6fa6-6fc4-4331-84b1-2b999e1fb111
# ╟─d65b73eb-fffd-4184-b690-cf45dcd6e175
# ╟─13705228-b1d5-4baa-99d1-810543950668
# ╟─37d85758-2a7c-461e-bf01-333cbdeca02e
# ╟─3f82e165-635d-4b40-9d72-68051eb34e0f
# ╟─1426fadd-f442-405c-8857-8f0619b4d7e7
# ╟─87339f91-30f2-4604-be23-1159a6b1dfd5
# ╟─e2830e26-266e-43c8-a506-a64616b5a8e9
# ╟─533b873d-a828-42a5-8412-2bf79a1af169
# ╟─46a01c46-54f7-4f86-b3ee-cfc9ef4515ac
# ╟─f594b900-1d22-4c10-927e-bae7e82596c6
# ╟─88aaa19a-b4e2-4b5a-9e6e-db5d5e272036
# ╟─21c6be91-61e7-4550-9478-2a5c78587506
# ╟─fdaa19eb-a225-4315-8a28-6ecd8cde8caa
# ╟─82c8d26d-c641-472a-8543-36e2de2647d7
# ╟─8764cabf-4a00-418c-b812-53a791572338
# ╟─8b88cee6-3643-4277-b2bc-9568199ca461
# ╟─3573a709-37a5-4fec-9121-1f0a70a17910
# ╟─1c309a37-0c41-4e29-bcc1-55f8cc9214aa
# ╟─0d5a71d7-b3fa-493c-8f83-b8e8bdde6cf5
# ╟─c2e9e9a9-6dd7-4f9c-8140-2d5976fcc8eb
# ╟─67cdb61f-43d2-45c3-90db-f5a94beac805
# ╟─7198c746-236b-42e3-a248-23e847c189d6
# ╟─f3653023-ac63-4b9d-8afa-7706db428df7
# ╟─c34395b0-c814-4134-9c1a-e2a6f7253a31
# ╟─0e115290-e74b-4065-bf4e-57bcee7ce250
# ╟─50abc53c-36ac-4e1d-aa33-4fc542cb2862
# ╟─aa629539-d96b-411a-91d1-d43932de869a
# ╟─4aa4dbe3-b071-444f-ae18-0988d8937f60
# ╟─fc4aa8e8-abf5-4d68-8865-c3ed42dd4fce
# ╟─287764da-1a5d-4a3e-93ef-0b2216eaecc8
# ╟─b4eb9302-3ddf-4b46-a09d-2018748bed1f
# ╟─5ada8541-9e34-4cec-9e66-a39e75d0e268
# ╟─ce189ed7-ba22-4738-bc64-85a7255c6cd6
# ╟─e85993df-cf07-4480-9e53-8210ecbcf9f9
# ╟─a1cd9ae9-27e6-4124-b3af-369d6a51692a
# ╟─99b79622-3427-4d29-a0e0-bbe0c22cbb35
# ╟─8e7f01e8-66d8-4a61-950c-1d6f97336e91
# ╟─2c82023c-9aff-4a41-9dc9-47bf2c9b15b1
# ╟─a4001eb2-32ad-46a1-9002-324ebf71bd25
# ╟─f046ae5f-2b8b-42fc-8d70-133c4e9c725c
# ╟─c271f654-8f2a-4720-8611-63bf946d4b73
# ╟─8d80bca6-44f5-431e-b892-7bb47074379c
# ╟─b09b6bd3-7b2a-4646-9996-4cfe55c3acfc
# ╟─d77ed377-9912-4535-9f27-a2506ce3ad2a
# ╟─7f55f4c8-63da-4cbd-938f-349914e432df
# ╟─adcab120-9262-4c24-931d-ce089414a45d
# ╟─a7695d30-00cd-4000-8992-1c93e99506ce
# ╟─7d1feb9a-31c3-4708-8d40-38fb3136344a
# ╟─959d48f7-fd7d-4342-8693-e3e73739a75b
# ╟─b8173564-fffd-4a10-b5c4-06caa139df87
# ╟─76482358-54c6-4685-9b47-a7a02bb67975
# ╟─3ccd290a-df66-4a36-b488-3ab7d588668c
# ╟─4ed852d4-6de1-4ae7-b3f7-6934fc261b18
# ╟─910a7054-a6e9-4e08-8e8a-1194eaa5aa02
# ╟─cc927e4d-2814-41c1-99bc-1ed344caaac2
# ╟─7c02cc51-4284-4743-8ad4-bae13f9414b2
# ╟─5c7b92c8-4190-402e-855a-7f48264fb413
# ╟─b94b7cca-10d3-40c0-987e-5b9a8a46fba3
# ╟─e9b1c327-3867-4c0e-8d6f-85ae2c59d8eb
# ╟─5ac58cac-9dc6-40ca-8524-ca05768b062e
# ╟─fea6cd9b-9bbe-47ae-abb5-1729eec449b7
# ╟─d7923836-03cd-478f-be58-99b99af2717e
# ╟─8c600e1c-50da-424b-b194-1bc2d9427ecc
# ╟─8a4e8006-67b3-4bdc-8bc6-5dde34af0bed
# ╟─9486cc7a-acef-4d66-9b8a-dc6da9ddf94e
# ╟─b0a96340-f28f-403e-995e-cf4853e6c9f8
# ╟─13ecc6b8-ffd4-4dba-8bef-6e51aff98642
# ╟─b82e97e7-96f3-4782-8ad0-c0aa5f85f89f
# ╟─9de1d64f-6f83-4856-9240-363a76848b48
# ╟─8329ec8f-9df0-41fb-bccf-5bb6b1800b67
# ╟─9a83ce8e-10a1-43da-b712-85a0a1603d95
# ╟─29ec0ce6-cc3a-4700-89bf-fe267e0e4106
# ╟─c101b031-ed89-414b-b5bb-ceda4b32cb30
# ╟─0e70982c-bd4d-4deb-a7ed-1ce10e1e6311
# ╟─2ff7733c-4e14-498c-8fcf-b75987a49df1
# ╟─45134982-845c-4340-8149-e111cf72a7a8
# ╟─98d0c2c2-4d6b-499e-a84d-871e35f6ab98
# ╟─935a06da-0926-46f5-a4ab-33344d0b0be8
# ╟─6b71002c-49fa-4d6a-900d-fd49ed5b7d1d
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
