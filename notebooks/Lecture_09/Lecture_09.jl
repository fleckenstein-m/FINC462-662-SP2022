### A Pluto.jl notebook ###
# v0.18.1

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

# ╔═╡ f78f3c79-46e0-42d1-93a3-91cbd7ccb371
#Set-up packages
begin
	
	using DataFrames, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, XLSX, Luxor
	
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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Forwards
	</b> <p>
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

# ╔═╡ 61887938-ec20-45c9-8ab8-b812fefcda3c
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
<input type="checkbox" value="">Understand and calculate forward rates.<br><br>
<input type="checkbox" value="">Understand how forward rates and spot rates are connected.<br><br>
<input type="checkbox" value="">Know the Expectation Hypothesis and use it to interpret expectations about Fed Monetary Policy.<br><br>
<input type="checkbox" value="">Understand the relation between forward rates and forward contracts.<br><br>
<input type="checkbox" value="">Value a forward rate agreement.<br><br>
</fieldset>      
	"""
end

# ╔═╡ d1b0ba85-b06b-4f01-af36-4c6f61e72607
md"""
# Forward Rates
"""

# ╔═╡ e0bd6de3-325d-4684-a371-d6957f96f664
md"""
- Lets' consider the following example.
- Suppose, XYZ Widgets has made a sale on credit. The client will pay $100mm in six months. XYZ does not have cash flow needs in six months, but will be making a capital investment in 12 months.

"""

# ╔═╡ ae82f174-51f0-40f6-a85b-68b2cc188e9f
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(14)
		tickline(pt1, pt3,
		    finishnumber=1,
		    major=1)
		fontsize(24)
		fontface("Georgia")
		label("Today", :N, pt1, offset=20) 
		label("Receive \$100mm", :N, pt2, offset=20) 
		label("Capital Investment", :N, pt3, offset=20) 
		# sethue("red")
		# Luxor.arrow(pt1, Point(-250, -50), Point(-100, -50), pt2)
	end 900 150
	end
end

# ╔═╡ 1fcd390e-8fb7-442c-bba9-f229b89fd2e8
md"""
##
"""

# ╔═╡ e10efd0c-a0e1-400d-873b-0ba958ee49f5
md"""
- **What should XYZ do with the \$100mm?**
  1. Keep it in a safe → will still have $100mm at t = 1
"""

# ╔═╡ 219ee1eb-84a9-44ed-8081-6da40084dc93
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(14)
		tickline(pt1, pt3,
		    finishnumber=1,
		    major=1)
		fontsize(24)
		fontface("Georgia")
		label("Today", :N, pt1, offset=20) 
		label("Receive \$100mm", :N, pt2, offset=20) 
		label("Capital Investment", :N, pt3, offset=20) 
		sethue("red")
		Luxor.arrow(Point(0,-75),Point(350,-75))
		label("+\$100mm", :N, Point(350,-75), offset=20) 
	end 900 300
	end
end

# ╔═╡ ec964651-e7b7-48d9-a93e-9563c948890f
md"""
##
"""

# ╔═╡ 17341757-a1dd-4ab1-873f-f091bad5941d
md"""
- **What should XYZ do with the \$100mm?**
  1. Keep it in a safe → will still have $100mm at t = 1.
  2. Invest in a six-month Treasury note at t = 0.5 at the then-prevailing interest rate for another six months.
     - Let the six-month Treasury rate (semi-annually compounded) at time t=0.5 be $r(0.5, 1)\equiv r_{0.5,1}$. Note that we do *not* know today at t=0 what this rate will be.
     - Then the cash flow at t=1 is $100 \times \left( 1+\frac{r_{0.5→1}}{2}\right)$
"""

# ╔═╡ 5924f10c-b93a-433c-86a6-9adf5950e168
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(14)
		tickline(pt1, pt3,
		    finishnumber=1,
		    major=1)
		fontsize(24)
		fontface("Georgia")
		label("Today", :N, pt1, offset=20) 
		label("Receive \$100mm", :N, pt2, offset=20) 
		label("Capital Investment", :N, pt3, offset=20) 
		sethue("red")
		Luxor.arrow(Point(0,-75),Point(350,-75))
		label("+\$100mm ( 1+ r₀.₅,₁/2 )", :N, Point(350,-75), offset=20) 
	end 1000 300
	end
end

# ╔═╡ c4b7668d-2e0c-4029-a8ab-52259d680b8a
md"""
##
"""

# ╔═╡ b3a2664f-c62a-4ab2-8d4a-90713a01175f
md"""
- **What should XYZ do with the \$100mm?**
  1. Keep it in a safe → will still have $100mm at t = 1.
  2. Invest in a six-month Treasury note at t = 0.5 at the then-prevailing interest rate for another six months.
     - Let the six-month Treasury rate (semi-annually compounded) at time t=0.5 be $r(0.5, 1)\equiv r_{0.5,1}$. Note that we do *not* know today at t=0 what this rate will be.
     - Then the cash flow at t=1 is $100 \times \left( 1+\frac{r_{0.5→1}}{2}\right)$
  3. Enter into a contract today that let's XYZ invest the \$100mm for six-months starting at t=0.5 at an interest rate of $f_{0.5,1}$. 
     - Note that this interest rate is agreed upon today and thus known (whereas $r_{0.5,1}$ is not known today at t=0).
     - What should this interest rate be?
"""

# ╔═╡ a64e70ba-4d8e-4c60-a381-986bb4956ed7
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(14)
		tickline(pt1, pt3,
		    finishnumber=1,
		    major=1)
		fontsize(24)
		fontface("Georgia")
		label("Today", :N, pt1, offset=20) 
		label("Receive \$100mm", :N, pt2, offset=20) 
		label("Capital Investment", :N, pt3, offset=20) 
		sethue("blue")
		Luxor.arrow(Point(0,-75),Point(350,-75))
		label("+\$100mm ( 1+ f₀.₅,₁/2 )", :N, Point(350,-75), offset=20) 
	end 1000 300
	end
end

# ╔═╡ 8575019d-63f4-4c61-b3fd-748ff312f6f6
md"""
# Forward Rates
"""

# ╔═╡ 5eb248a3-1521-4f77-88bc-2b35275d3104
md"""
A forward rate $f(T_1,T_2)≡f_{T_1,T_2}$ is the interest rate set *today* at time t=0 for an investment from time $T_1$ to $T_2$.
"""

# ╔═╡ 75f9e75d-13a3-4efb-b2dc-9fda809c6eb0
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=T$n", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(pt2, Point(125, -75), Point(200, -75), pt3)
		label("f(T1,T2)", :N, Point(-350,-10), offset=20) 
	end 900 300
	end
end

# ╔═╡ cb8cf80b-e800-4fc9-a07d-21032cbc107b
md"""
##
"""

# ╔═╡ 25aa5bec-668c-45fd-a820-18862d0052a8
md"""
- **What must fhe forward rate $f_{0.5,1}$ be?**
- It turns out that forward rates are related to spot rates (zero-coupon yields) through the Law of One Price.
- This means that we can synthetically create a forward rate agreement using two zero-coupon bonds. Let's see how this can be done.
"""

# ╔═╡ b531c923-f0b9-4830-be89-c22bea11c6d1
begin
	let
		function make_label(n, pos;
          startnumber  = 0,
          finishnumber = 1,
          nticks = 1)
    	  Luxor.text("t=T$n", pos + (0, 30), halign=:left)
		end
	
	@drawsvg begin
		background("white")
		fontsize(12)
		sethue("black")
		pt1 = Point(-350, 0)
		pt2 = Point(0, 0)		
		pt3 = Point(350, 0)	
		fontsize(20)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(pt2, Point(125, -75), Point(200, -75), pt3)
		label("f(0.5,1.0) = ?", :N, Point(-350,-10), offset=20) 
	end 900 300
	end
end

# ╔═╡ 56800364-65bc-4071-8692-8989d903b412
begin
	y6m_1 = 2 #percent
	y1y_1 = 3 #percent
	T6m_1 = 0.5
	T1y_1 = 1.0
	P6m_1 = roundmult(100/(1+y6m_1/200)^(2*T6m_1),1e-4)
	P1y_1 = roundmult(100/(1+y1y_1/200)^(2*T1y_1),1e-4)
	f_1 = roundmult(2*((1+y1y_1/200)^2/(1+y6m_1/200)-1),1e-6)
	display("")
end

# ╔═╡ e61dc458-0d56-4f93-aa3c-a01729f45c80
md"""
##
"""

# ╔═╡ 7a2318b5-77aa-41c4-8076-9052dfe40894
md"""
- Suppose we observe the following zero-coupon bonds
Bond        | Time-to-maturity $T$  |  Price   | Spot Rate
-----------:|----------------------:|---------:|-----------:
X           | $(T6m_1)              | $(P6m_1) | $(y6m_1) %
Z           | $(T1y_1)              | $(P1y_1) | $(y1y_1) %
"""

# ╔═╡ 42461a91-61cf-426c-a950-c7084a1f132e
md"""
##
"""

# ╔═╡ 3c6ba609-b316-4082-8c75-9b5da8928bc2
md"""
- Let's consider a portfolio of Bond X and Bond Z.
- Suppose we invest in $x$ units of Bond X and $z$ units in Bond Z.
  - For instance, $x=1$ means that we buy one Bond X (with 100 par amount).
- Recall that when we agree to the forward rate $f_{0.5,1}$ we invest an amount, say $100, at t=0.5. This is a cash-outflow.
- In turn, we have a cash inflow of principal plus interest at time t=1.
- Thus, in order to replicate the forward rate agreement, we need to have a cash outflow at t=0.5 and a cash inflow at t=1.0.
- Let's replicate this pattern using zero-coupon bonds.
"""

# ╔═╡ e9cb4d2d-1e50-4f86-a8ad-d4e09649cdb0
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(pt2, Point(125, -75), Point(200, -75), pt3)
		Luxor.arrow(pt2, pt2 + (0, +75))
		Luxor.arrow(pt3, pt3 + (0, -75))
		label("f(0.5,1.0) = ?", :N, Point(-350,-10), offset=20) 
		label("-100", :N, pt2 + (30,80)) 
		label("+100 ( 1+ f(0.5,1)/2 )", :N, pt3 + (0,-80)) 
	end 900 300
	end
end

# ╔═╡ 0b40db04-f458-4843-a5af-2eb23602fbc0
md"""
##
"""

# ╔═╡ f99ac143-0216-4ed5-9c4a-774161e62334
Markdown.parse("
- To get a cash outflow at t=0.5, we short 1 unit of Bond X.
  - The short requires us to pay back the par amount of 100 at t=0.5, thus creating a cash outflow.
- By taking the short position in Bond X, we create a cash inflow today in the amount of the market price of Bond X.
- However, in the forward rate agreement, we have no cash flow today at t=0.
- Thus, we buy ``z`` units of Bond Z such that we pay as much for the position in Bond Z as we receive from the short position in Bond X. In doing this, we have a zero cash flow today.
- Since we short ``x=1`` units of Bond X, we receive the market price of Bond X in the amount of P= \\\$$(P6m_1) today. 
- Since the price of 1 unit of Bond Z is P= \\\$$(P1y_1), we need to buy more than one unit. Specifically, we buy
``\$z=\\frac{ $(P6m_1)}{$(P1y_1)}=$(roundmult(P6m_1/P1y_1,1e-4)) \\textrm{ units}\$ `` 
")

# ╔═╡ 0099b4ec-061d-4370-ac30-34339a66b5ce
md"""
##
"""

# ╔═╡ 3f3825d1-6ac8-4608-9cb7-77e758f625e4
Markdown.parse("

Bond  | Units   |  Cash Flow t=0 | Cash Flow t=0.5 | Cash Flow t=1.0
-----:|--------:|---------------:|----------------:|-------------:
X     | ``x=-1``     | +$(P6m_1)              | -100               | 0  
Z     | ``z=$(roundmult(P6m_1/P1y_1,1e-4))``     | -$(P6m_1)              | 0| $(roundmult(P6m_1/P1y_1*100,1e-4))  
Portfolio|      |      0          |       -100          | $(roundmult(P6m_1/P1y_1*100,1e-4))
")

# ╔═╡ cdfe0473-9a2b-4310-804e-f497e68f3471
md"""
##
"""

# ╔═╡ b62e3e14-e3fa-4ae0-acdd-aced322a5432
Markdown.parse("
- This means that we can lock in a six-month interest rate of ``$(roundmult((P6m_1/P1y_1-1)*100,1e-4))`` percent to invest 100 starting in six months from now (at t=0.5) for another six months until time t=1.
- The corresponding annualized rate is ``$(roundmult((P6m_1/P1y_1-1)*100*2,1e-4))`` percent.
- Thus, by no arbitrage, the forward rate ``f_{$(T6m_1),$(T1y_1)}`` must be equal to $(roundmult((P6m_1/P1y_1-1)*100*2,1e-4)) percent.
``\$f_{$(T6m_1),$(T1y_1)} \\stackrel{!}{=} $(roundmult((P6m_1/P1y_1-1)*2,1e-6))\$``
")

# ╔═╡ 90be5edd-4515-47bb-bf12-26dd492afa6e
md"""
##
"""

# ╔═╡ cb7238f5-5f98-4bd1-b973-e4614832d2d7
Markdown.parse("
- Suppose that someone agrees to a forward rate ``f_{0.5,1.0}=0.03``.
- Can we lock in a risk-free profit?
- The answer is yes. Since the forward rate of 3% is too low relative to what it should be, we **borrow** at the forward rate and invest in the two bonds (Bond X and Bond z) that we used to replicate the forward rate agreement.
- Let's illustrate this in the next table.
")

# ╔═╡ 33110efa-f7d7-410a-a170-b0ba8bc1da27
md"""
##
"""

# ╔═╡ faad21f6-2ee1-47ab-b503-1e6b6f51c21e
Markdown.parse("

Bond  | Units   |  Cash Flow t=0 | Cash Flow t=0.5 | Cash Flow t=1.0
-----:|--------:|---------------:|----------------:|-------------:
Forward| 1      | 0              | **+**100        | ``-100\\times (1+\\frac{f(0.5,1)}{2}) = -$(roundmult(100*(1+0.03/2),1e-4))``
X     | ``x=-1``     | +$(P6m_1)              | -100               | 0  
Z     | ``z=$(roundmult(P6m_1/P1y_1,1e-4))``     | -$(P6m_1)              | 0| $(roundmult(P6m_1/P1y_1*100,1e-4))  
Portfolio|      |      0          |       -100          | $(roundmult(P6m_1/P1y_1*100 - 100*(1+0.03/2),1e-4))
")

# ╔═╡ 844183ad-f5a6-4735-bae1-0592aeafe398
Markdown.parse("
- Thus, if someone agrees a forward rate of ``f_{0.5,1.0}=3``%, we can earn a riskfree profit of \$ $(roundmult(P6m_1/P1y_1*100 - 100*(1+0.03/2),1e-4)) for each \$100 invested.
")

# ╔═╡ 298aac39-e42e-409b-9642-944531ac216d
md"""
##
"""

# ╔═╡ 15c836cb-fbe4-4494-9b92-20001d882664
md"""
- In the previous example, we have shown how to use zero-coupon bonds to calculate forward rates.
- Alternatively, we can use spot rates. Let's illustrate this next by using the same two bonds as in the previous example.
"""

# ╔═╡ 73a9d891-75ea-480e-98b1-5e73493c61c7
md"""
##
"""

# ╔═╡ 33931907-e196-4325-9c8e-d2ed9a21d49f
md"""
- Suppose we observe the following zero-coupon bonds
Bond        | Time-to-maturity $T$  |   Spot Rate
-----------:|----------------------:|---------:
X           | $(T6m_1)              | $(y6m_1) %
Z           | $(T1y_1)              | $(y1y_1) %

- We want to determine the forward rate ``f_{0.5, 1}`` for investing \$1 starting in six months for another six months.
- The basic idea is that we consider two investment strategies at t=0, where one strategy uses the forward rate and the other uses spot rates only. The maturity of these two investment strategies is equal to the maturity of the forward rates. 
  - In this example the forward rate ends at t=1.0, so the two investment strategies will invest $1 from t=0 to t=1.0.
"""

# ╔═╡ 1243c98c-d0d7-408d-bc4e-849552fa5305
md"""
##
"""

# ╔═╡ fd3922c6-d5a2-4124-b74f-6cffc6a529cd
md"""
- **Consider two different investment strategies**
  1. Invest \$1 at the six-month spot rate ``r_{0.5}`` today and agree to a forward rate agreement at ``f_{0.5, 1}`` for the second six-month period until t=1.0.
  2. Invest \$1 today at the one-year spot rate $r_{1.0}$ for one year.
"""

# ╔═╡ 8e83dcfb-970f-40ec-a1e0-a82c68f64964
md"""
##
"""

# ╔═╡ 235135fe-bc62-46d0-9a7c-a2a0458e0de1
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
		Luxor.text("Investment Strategy 1",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("blue")
		Luxor.arrow(pt1, Point(-200, -75), Point(-100, -75), pt2)
		sethue("red")
		Luxor.arrow(pt2, Point(125, -75), Point(200, -75), pt3)
		# label("\$1 x ( 1+ r(0.5)/2 )", :N, pt1 + (175,-60)) 
		label("( 1+ $(y6m_1)%/2)", :N, pt1 + (175,-60)) 
		label("( 1+ f(0.5,1)/2 )", :N, pt2 + (175,-60)) 
		Luxor.arrow(pt3, pt3 + (0, -50))
		label("-\$1", :N, Point(-350,-10), offset=20) 
		label("+\$1 x ( 1+ $(y6m_1)%/2 )", :N, pt3 + (30,-80)) 
		label("       x ( 1+ f(0.5,1)/2 )", :N, pt3 + (30,-55)) 
	end 950 300
	end
end

# ╔═╡ 01af2967-477b-44fe-a479-0ab5accd4a2f
md"""
##
"""

# ╔═╡ bebe1514-2120-4d5c-9245-a0310dd8622a
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
		Luxor.text("Investment Strategy 2",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(pt1, Point(-100, -75), Point(100, -75), pt3)
		label("-\$1", :N, Point(-350,-10), offset=20) 
		label("+\$1 x ( 1+ $(y1y_1)%/2 )² ", :N, pt3 + (0,-30)) 
		
	end 950 300
	end
end

# ╔═╡ 9c3498c4-3aa6-4c65-853b-f13333295485
md"""
##
"""

# ╔═╡ 91691be0-c0f8-4ae7-b5e7-6ecb044abf03
Markdown.parse("
- Both strategies involve an initial investment at t = 0 of \$ 1.
- The cash flows from both stragies are risk-free and known as of today.
- By no arbitrage, Strategy 1 and Strategy 2 must have the same cash flow at t=1.
``\$\\left(1+ \\frac{$(y6m_1)\\%}{2} \\right) \\times \\left(1+\\frac{f_{0.5,1}}{2} \\right) \\stackrel{!}{=} \\left( 1+\\frac{$(y1y_1)\\%}{2}\\right)^2 \$``
- Thus, the forward rate ``f_{0.5,1}`` is 
``\$ f_{0.5,1} = \\frac{\\left( 1+\\frac{$(y1y_1)\\%}{2}\\right)^2}{\\left(1+ \\frac{$(y6m_1)\\%}{2} \\right)} -1 = $(f_1) = $(f_1*100)\\%\$``
")

# ╔═╡ 1939288d-5e24-43a0-b5c7-d7c6bd202524
md"""
# Calculating Forward Rates
"""

# ╔═╡ 16777168-522f-469b-a1e1-566d7a2b8204
md"""
- To illustrate how the approach we took in the previous example can be applied to calculate forward rates for other periods, let's consider the following spot rates.
- The goal is to calculate the six-months forward rates starting in six-months from now, starting at 12-months from now, etc.
  - Assume that all spot rates are semi-annually compounded.
"""

# ╔═╡ f07c5a3d-d943-458c-abfb-4a57b879f4a6
@bind bttn_1 Button("Reset")

# ╔═╡ acda8937-b591-4599-840b-34cd0267339b
begin
bttn_1
	md"""
	- 0.5-year spot rate $r_{0.5}$ [%]: $(@bind r05_2 Slider(0:0.10:10, default=2, show_value=true))
	- 1.0-year spot rate $r_{1.0}$ [%]: $(@bind r10_2 Slider(0:0.10:10, default=3, show_value=true))
	- 1.5-year spot rate $r_{1.5}$ [%]: $(@bind r15_2 Slider(0:0.10:10, default=3.5, show_value=true))
	- 2.0-year spot rate $r_{2.0}$ [%]: $(@bind r20_2 Slider(0:0.10:10, default=3, show_value=true))
	- 2.5-year spot rate $r_{2.5}$ [%]: $(@bind r25_2 Slider(0:0.10:10, default=4, show_value=true))
	- 3.0-year spot rate $r_{3.0}$ [%]: $(@bind r30_2 Slider(0:0.10:10, default=4.5, show_value=true))
	- 3.5-year spot rate $r_{3.5}$ [%]: $(@bind r35_2 Slider(0:0.10:10, default=4.75, show_value=true))
	- 4.0-year spot rate $r_{4.0}$ [%]: $(@bind r40_2 Slider(0:0.10:10, default=5.00, show_value=true))
	- 4.5-year spot rate $r_{4.5}$ [%]: $(@bind r45_2 Slider(0:0.10:10, default=5.10, show_value=true))
	- 5.0-year spot rate $r_{5.0}$ [%]: $(@bind r50_2 Slider(0:0.10:10, default=5.25, show_value=true))

	"""
end

# ╔═╡ afa00268-983f-4960-a93c-0135e7081e27
begin
	rVec_2 = [r05_2,r10_2,r15_2,r20_2,r25_2,r30_2,r35_2,r40_2,r45_2,r50_2]
	
	f05_10_2 = 2*((1+r10_2/200)^(2*1.0)/(1+r05_2/200)^(2*0.5) -1)
	f10_15_2 = 2*((1+r15_2/200)^(2*1.5)/(1+r10_2/200)^(2*1.0) -1)
	f15_20_2 = 2*((1+r20_2/200)^(2*2.0)/(1+r15_2/200)^(2*1.5) -1)
	f20_25_2 = 2*((1+r25_2/200)^(2*2.5)/(1+r20_2/200)^(2*2.0) -1)
	f25_30_2 = 2*((1+r30_2/200)^(2*3.0)/(1+r25_2/200)^(2*2.5) -1)
	f30_35_2 = 2*((1+r35_2/200)^(2*3.5)/(1+r30_2/200)^(2*3.0) -1)
	f35_40_2 = 2*((1+r40_2/200)^(2*4.0)/(1+r35_2/200)^(2*3.5) -1)
	f40_45_2 = 2*((1+r45_2/200)^(2*4.5)/(1+r40_2/200)^(2*4.0) -1)
	f45_50_2 = 2*((1+r50_2/200)^(2*5.0)/(1+r45_2/200)^(2*4.5) -1)
	fVec_2 = [f05_10_2,f10_15_2,f15_20_2,f20_25_2,f25_30_2,f30_35_2,f35_40_2,f40_45_2,f45_50_2]

	f01_30_2 = (((1+r30_2/200)^(2*3)/(1+r10_2/200)^(2*1))^(1/(2*2))-1)*2
	
	strf05_10_2 = "2*((1+$(roundmult(r10_2/100,1e-6)/2))^{2*1.0}/(1+$(r05_2/100)/2)^{2*0.5} -1)"
	strf10_15_2 = "2*((1+$(roundmult(r15_2/100,1e-6)/2))/2))^{2*1.5}/(1+$(r10_2/100)/2)^{2*1.0} -1)"
	strf15_20_2 = "2*((1+$(roundmult(r20_2/100,1e-6)/2))/2))^{2*2.0}/(1+$(r15_2/100)/2)^{2*1.5} -1)"
	strf20_25_2 = "2*((1+$(roundmult(r25_2/100,1e-6)/2))/2))^{2*2.5}/(1+$(r20_2/100)/2)^{2*2.0} -1)"
	strf25_30_2 = "2*((1+$(roundmult(r30_2/100,1e-6)/2))/2))^{2*3.0}/(1+$(r25_2/100)/2)^{2*2.5} -1)"
	strf30_35_2 = "2*((1+$(roundmult(r35_2/100,1e-6)/2))/2))^{2*3.5}/(1+$(r30_2/100)/2)^{2*3.0} -1)"
	strf35_40_2 = "2*((1+$(roundmult(r40_2/100,1e-6)/2))/2))^{2*4.0}/(1+$(r35_2/100)/2)^{2*3.5} -1)"
	strf40_45_2 = "2*((1+$(roundmult(r45_2/100,1e-6)/2))/2))^{2*4.5}/(1+$(r40_2/100)/2)^{2*4.0} -1)"
	strf45_50_2 = "2*((1+$(roundmult(r50_2/100,1e-6)/2))/2))^{2*5.0}/(1+$(r45_2/100)/2)^{2*4.5} -1)"
	strfVec_2 = [strf05_10_2,strf10_15_2,strf15_20_2,strf20_25_2,strf25_30_2,strf30_35_2,strf35_40_2,strf40_45_2,strf45_50_2]
	display("")	
end

# ╔═╡ 24646b27-e765-4340-aec1-b45295d14644
md"""
##
"""

# ╔═╡ 95c45360-da9e-4bb6-894d-70b0a1a85b42
Markdown.parse("
- Calculate the forward rate ``f_{1,1.5}`` starting in 1-year from now to invest for another six months.
1. Strategy 1: Invest at the 1.0-year spot rate and invest at the forward rate ``f_{1,1.5}`` for another six months starting at t=1.
``\$ \\left(1+ \\frac{r_{1.0}}{2}\\right)^2 \\times \\left(1+ \\frac{f_{1,1.5}}{2}\\right)\$``

")

# ╔═╡ 15272a5f-dcef-4ee6-8ab1-30479a627bf6
Markdown.parse("
2. Strategy 2: Invest at 1.5-year spot rate.
``\$ \\left(1+ \\frac{r_{1.5}}{2}\\right)^3\$``

")

# ╔═╡ 753ae53b-fcf8-4085-af43-c77229ff1704
md"""
##
"""

# ╔═╡ d6db6b29-60f4-45d7-8015-8c93d8dae7e7
Markdown.parse("
3. Strategy 1 and 2 must have the same cash flow at t=1.5.
``\$ \\left(1+ \\frac{r_{1.0}}{2}\\right)^2 \\times \\left(1+ \\frac{f_{1,1.5}}{2}\\right) \\stackrel{!}{=} \\left(1+ \\frac{r_{1.5}}{2}\\right)^3\$``
- Plugging in the values for the spot rates.
``\$ \\left(1+ \\frac{$r10_2\\%}{2}\\right)^2 \\times \\left(1+ \\frac{f_{1,1.5}}{2}\\right) \\stackrel{!}{=} \\left(1+ \\frac{$r15_2\\%}{2}\\right)^3\$``

")

# ╔═╡ aac995ac-95d3-4e4f-a3df-27e18f740386
md"""
##
"""

# ╔═╡ 6a723abc-8040-4355-9c64-82d05d9e8275
Markdown.parse("
- Solve for ``f_{1.0,1.5}``

``\$ \\left(1+ \\frac{f_{1,1.5}}{2}\\right) = \\frac{\\left(1+ \\frac{$r15_2\\%}{2}\\right)^3}{\\left(1+ \\frac{$r10_2\\%}{2}\\right)^2}\$``

``\$ f_{1,1.5} = 2 \\times \\left( \\frac{\\left(1+ \\frac{$r15_2\\%}{2}\\right)^3}{\\left(1+ \\frac{$r10_2\\%}{2}\\right)^2} - 1\\right)\$``

``\$ f_{1,1.5} = $(roundmult(f10_15_2,1e-6))=$(roundmult(f10_15_2*100,1e-4))\\%\$``
")

# ╔═╡ ee8cb6db-e002-41f6-8c71-aae043041dcf
md"""
##
"""

# ╔═╡ 7badc2ed-da19-4286-92b1-10279b0ffcb1
Markdown.parse("
- Calculate the forward rate ``f_{1.5,2.0}`` starting in 1.5-year from now to invest for another six months.
1. Strategy 1: Invest at the 1.5-year spot rate and invest at the forward rate ``f_{1.5,2.0}`` for another six months starting at t=1.5.
``\$ \\left(1+ \\frac{r_{1.5}}{2}\\right)^{2\\times 1.5} \\times \\left(1+ \\frac{f_{1.5,2.0}}{2}\\right)^{2\\times 0.5}\$``

")

# ╔═╡ 7bb03222-7f16-4cb7-96fc-647c57447309
md"""
##
"""

# ╔═╡ 8cec18c4-f464-46ef-85e9-7ad4e059b973
Markdown.parse("
2. Strategy 2: Invest at 2.0-year spot rate.
``\$ \\left(1+ \\frac{r_{2.0}}{2}\\right)^{2\\times 2}\$``

")

# ╔═╡ d138271f-88d4-42eb-853d-9443d353ab32
md"""
##
"""

# ╔═╡ e64ee014-0971-4162-8869-04f71228a7f1
Markdown.parse("
3. Strategy 1 and 2 must have the same cash flow at t=2.0.
``\$ \\left(1+ \\frac{r_{1.5}}{2}\\right)^3 \\times \\left(1+ \\frac{f_{1.5,2.0}}{2}\\right) \\stackrel{!}{=} \\left(1+ \\frac{r_{2.0}}{2}\\right)^4\$``

")

# ╔═╡ c8f89c41-19e5-4fc9-ab30-08c0d669ad43
md"""
##
"""

# ╔═╡ b3e89143-09cb-4274-8a5a-26c3a17cfe84
Markdown.parse("
- Plugging in the values for the spot rates.
``\$ \\left(1+ \\frac{$r15_2\\%}{2}\\right)^3 \\times \\left(1+ \\frac{f_{1.5,2.0}}{2}\\right) \\stackrel{!}{=} \\left(1+ \\frac{$r20_2\\%}{2}\\right)^4\$``
- Solve for ``f_{1.5,2.0}``

``\$ \\left(1+ \\frac{f_{1.5,2.0}}{2}\\right) = \\frac{\\left(1+ \\frac{$r20_2\\%}{2}\\right)^4}{\\left(1+ \\frac{$r15_2\\%}{2}\\right)^3}\$``

``\$ f_{1.5,2.0} = 2 \\times \\left( \\frac{\\left(1+ \\frac{$r20_2\\%}{2}\\right)^4}{\\left(1+ \\frac{$r15_2\\%}{2}\\right)^3} - 1\\right)\$``

``\$ f_{1.5,2.0} = $(roundmult(f15_20_2,1e-6))=$(roundmult(f15_20_2*100,1e-4))\\%\$``
")

# ╔═╡ 94bb4997-c2ad-4803-8181-dfe824f9019a
md"""
##
"""

# ╔═╡ 5ab35e41-d016-4919-820e-80f572e7a1ea
Markdown.parse("
- Repeating this process to ``f_{4.5,5.0}`` gives the following six-month forward rates
Forward Rate   | Value                                     | Calculation            
--------------:|------------------------------------------:|----------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_2*100,1e-4))\\%``   | ``$(strfVec_2[1])``
``f(1.0,1.5)``  | ``$(roundmult(f10_15_2*100,1e-4))\\%``   | ``$(strfVec_2[2])``
``f(1.5,2.0)``  | ``$(roundmult(f15_20_2*100,1e-4))\\%``   | ``$(strfVec_2[3])``
``f(2.0,2.5)``  | ``$(roundmult(f20_25_2*100,1e-4))\\%``   | ``$(strfVec_2[4])``
``f(2.5,3.0)``  | ``$(roundmult(f25_30_2*100,1e-4))\\%``   | ``$(strfVec_2[5])``
``f(3.0,3.5)``  | ``$(roundmult(f30_35_2*100,1e-4))\\%``   | ``$(strfVec_2[6])``
``f(3.5,4.0)``  | ``$(roundmult(f35_40_2*100,1e-4))\\%``   | ``$(strfVec_2[7])``
``f(4.0,4.5)``  | ``$(roundmult(f40_45_2*100,1e-4))\\%``   | ``$(strfVec_2[8])``
``f(4.5,5.0)``  | ``$(roundmult(f45_50_2*100,1e-4))\\%``   | ``$(strfVec_2[9])``

")

# ╔═╡ 50e93557-f381-4d56-915b-b76197dab0e0
md"""
##
"""

# ╔═╡ e980cabe-4924-4232-be56-1192ec21e30e
md"""
- In the previous example, we have calculated six-month forward rates.
- Let's consider next, how we calculate forward rates starting at some time t in the future for investing for another $n$ months.
- Let's start by calculating the forward rate $f_{1.0,3.0}$ starting in one year from now for investing for another two years
- We take a similar approach as in the previous examples.
- Strategy 1:
  - Invest for 1-year at the one-year spot rate starting today and then invest at the 2-year forward rate starting in year 1.
- Strategy 2:
  - Invest for 3-years at the three-year spot rate starting today.
"""

# ╔═╡ dd5360b3-a49f-4ded-99aa-b2cbd475a8ca
md"""
##
"""

# ╔═╡ ffec6b06-f96f-423c-82c6-40a78b7e8d0f
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
		Luxor.text("Investment Strategy 1",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=3,
		    major=5)
		box.(majticks,1,15,:fill)
		sethue("blue")
		Luxor.arrow(pt1, Point(-250, -75), Point(-200, -75), majticks[3])
		sethue("red")
		Luxor.arrow(majticks[3], Point(125, -75), Point(200, -75), pt3)
		label("( 1+ $(r10_2)%/2)^(2*1)", :N, pt1 + (175,-60)) 
		label("( 1+ f(1,3)/2 )^(2*2)", :N, pt2 + (175,-60)) 
		Luxor.arrow(pt3, pt3 + (0, -50))
		label("-\$1", :N, Point(-350,-10), offset=20) 
		label("+\$1 x ( 1+ $(r10_2)%/2 )^(2*1)", :N, pt3 + (25,-80)) 
		label("       x ( 1+ f(1,3)/2 )^(2*2)", :N, pt3 + (25,-55)) 
	end 950 300
	end
end

# ╔═╡ a2d3945a-1be0-4710-8207-ed78f0d28a5a
md"""
##
"""

# ╔═╡ 7227f1f8-83f3-411b-9f24-e28dfda6e4f9
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
		Luxor.text("Investment Strategy 2",  Point(-425,-120), halign=:left,  valign = :top)
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=3,
		    major=5)
		box.(majticks,1,15,:fill)
		sethue("green")
		Luxor.arrow(pt1, Point(-100, -75), Point(100, -75), pt3)
		label("( 1+ $(r30_2)%/2)^(2*3)", :N, pt1 + (375,-70)) 
		Luxor.arrow(pt3, pt3 + (0, -50))
		label("-\$1", :N, Point(-350,-10), offset=20) 
		label("+\$1 x ( 1+ $(r30_2)%/2 )^(2*3)", :N, pt3 + (20,-60)) 
		end 950 300
	end
end

# ╔═╡ 07b764cb-2ced-462a-88b5-a409a9c83775
md"""
##
"""

# ╔═╡ fa7c6f7d-0752-4c73-8485-c7e3305ad0c2
Markdown.parse("
- Strategy 1:
  - Invest for 1-year at the one-year spot rate starting today and then invest at the 2-year forward rate starting in year 1.

``\$\\left( 1+ \\frac{r_{1}}{2}\\right)^{2\\times 1} \\times \\left( 1+ \\frac{f_{1,3}}{2}\\right)^{2\\times 2}\$``

")

# ╔═╡ 095bd350-7631-4f58-ac07-690d20a2a115
md"""
##
"""

# ╔═╡ fd82b88e-bd1a-419e-8ea3-87846e7ec859
Markdown.parse("
- Strategy 2:
  - Invest for 3-years at the three-year spot rate starting today.
``\$\\left( 1+ \\frac{r_{3}}{2}\\right)^{2\\times 3}\$``

")

# ╔═╡ dc2ccb67-79f1-4143-9d7b-f3b391c9f723
md"""
##
"""

# ╔═╡ af1bbcd8-280d-409e-bf27-43809ebbff2f
Markdown.parse("
- Strategy 1 and 2 must have the same cash flow at t=3.
``\$\\left( 1+ \\frac{r_{1}}{2}\\right)^{2\\times 1} \\times \\left( 1+ \\frac{f_{1,3}}{2}\\right)^{2\\times 2} \\stackrel{!}{=}\\left( 1+ \\frac{r_{3}}{2}\\right)^{2\\times 3}\$``

")

# ╔═╡ db6ae21f-9f39-4555-ae90-eeec9e8ab318
md"""
##
"""

# ╔═╡ f3ac8072-17ca-4def-8a3f-8c72a26dfe07
Markdown.parse("
- Plugging in the values for the spot rates.
``\$\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2} \\times \\left( 1+ \\frac{f_{1,3}}{2}\\right)^{4} \\stackrel{!}{=}\\left( 1+ \\frac{$(r30_2)\\%}{2}\\right)^{6}\$``

``\$\\left( 1+ \\frac{f_{1,3}}{2}\\right)^{4}  = \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2}}\$``

``\$f_{1,3} = 2\\times \\left( \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6/4}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2/4}} -1\\right)\$``

``\$ f_{1,3} = $(roundmult(f01_30_2,1e-6)) = $(roundmult(f01_30_2*100,1e-4)) \\%\$``
")

# ╔═╡ c6f4c700-1c97-4927-bd86-b95013e5ebbf
md"""
##
"""

# ╔═╡ 15d63080-7bae-405e-96da-4a45a7601d6e
md"""
- This approach to calculating forward rates works in general.
- Specifically, when thinking about how to calculate forward rates, think in terms of how we can invest at different horizons. 
- In particular, suppose that we are considering $f_{T_1,T_2}$.
  - Buy a zero-coupon bond with maturity $T_2$.
  - Buy a zero-coupon bond with maturity $T_1$ and agree to a forward contract at a rate of $f_{T_1,T_2}$.
  - Since both strategies are risk-free, have the same investment, can be entered into today, and pay out at the same time, we can equate their final cash flows.
"""

# ╔═╡ 3d629b93-178b-48d9-83c4-e39529dd0255
md"""
# Term Structure and Expectations Hypothesis
"""

# ╔═╡ 34e8fe6c-ba82-425b-b31c-d3d9319af6f2
md"""
##
"""

# ╔═╡ 992f5676-c5f3-440a-b673-213bf4a9ca20
md"""
- **Upward-Sloping Yield Curve**
"""

# ╔═╡ 0f59ed23-a2c2-4495-a10d-0c49b40de3dc
@bind bttn_3 Button("Reset")

# ╔═╡ 48081c8f-234a-4f93-a142-594584a28653
begin
bttn_3
	md"""
	- 0.5-year spot rate $r_{0.5}$ [%]: $(@bind r05_3 Slider(0:0.10:10, default=2, show_value=true))
	- 1.0-year spot rate $r_{1.0}$ [%]: $(@bind r10_3 Slider(0:0.10:10, default=2.5, show_value=true))
	- 1.5-year spot rate $r_{1.5}$ [%]: $(@bind r15_3 Slider(0:0.10:10, default=3.0, show_value=true))
	- 2.0-year spot rate $r_{2.0}$ [%]: $(@bind r20_3 Slider(0:0.10:10, default=3.5, show_value=true))
	- 2.5-year spot rate $r_{2.5}$ [%]: $(@bind r25_3 Slider(0:0.10:10, default=4, show_value=true))
	- 3.0-year spot rate $r_{3.0}$ [%]: $(@bind r30_3 Slider(0:0.10:10, default=4.5, show_value=true))
	- 3.5-year spot rate $r_{3.5}$ [%]: $(@bind r35_3 Slider(0:0.10:10, default=5.0, show_value=true))
	- 4.0-year spot rate $r_{4.0}$ [%]: $(@bind r40_3 Slider(0:0.10:10, default=5.50, show_value=true))
	- 4.5-year spot rate $r_{4.5}$ [%]: $(@bind r45_3 Slider(0:0.10:10, default=6.0, show_value=true))
	- 5.0-year spot rate $r_{5.0}$ [%]: $(@bind r50_3 Slider(0:0.10:10, default=6.5, show_value=true))

	"""
end

# ╔═╡ 2eb91aff-402d-4f3d-aad1-d0634e77de22
begin
	rVec_3 = [r05_3,r10_3,r15_3,r20_3,r25_3,r30_3,r35_3,r40_3,r45_3,r50_3]
	
	f05_10_3 = 2*((1+r10_3/200)^(2*1.0)/(1+r05_3/200)^(2*0.5) -1)
	f10_15_3 = 2*((1+r15_3/200)^(2*1.5)/(1+r10_3/200)^(2*1.0) -1)
	f15_20_3 = 2*((1+r20_3/200)^(2*2.0)/(1+r15_3/200)^(2*1.5) -1)
	f20_25_3 = 2*((1+r25_3/200)^(2*2.5)/(1+r20_3/200)^(2*2.0) -1)
	f25_30_3 = 2*((1+r30_3/200)^(2*3.0)/(1+r25_3/200)^(2*2.5) -1)
	f30_35_3 = 2*((1+r35_3/200)^(2*3.5)/(1+r30_3/200)^(2*3.0) -1)
	f35_40_3 = 2*((1+r40_3/200)^(2*4.0)/(1+r35_3/200)^(2*3.5) -1)
	f40_45_3 = 2*((1+r45_3/200)^(2*4.5)/(1+r40_3/200)^(2*4.0) -1)
	f45_50_3 = 2*((1+r50_3/200)^(2*5.0)/(1+r45_3/200)^(2*4.5) -1)
	fVec_3 = [f05_10_3,f10_15_3,f15_20_3,f20_25_3,f25_30_3,f30_35_3,f35_40_3,f40_45_3,f45_50_3]

	f01_30_3 = (((1+r30_3/200)^(2*3)/(1+r10_3/200)^(2*1))^(1/(2*2))-1)*2
	
	strf05_10_3 = "2*((1+$(roundmult(r10_3/100,1e-6)/2))^{2*1.0}/(1+$(r05_3/100)/2)^{2*0.5} -1)"
	strf10_15_3 = "2*((1+$(roundmult(r15_3/100,1e-6)/2))/2))^{2*1.5}/(1+$(r10_3/100)/2)^{2*1.0} -1)"
	strf15_20_3 = "2*((1+$(roundmult(r20_3/100,1e-6)/2))/2))^{2*2.0}/(1+$(r15_3/100)/2)^{2*1.5} -1)"
	strf20_25_3 = "2*((1+$(roundmult(r25_3/100,1e-6)/2))/2))^{2*2.5}/(1+$(r20_3/100)/2)^{2*2.0} -1)"
	strf25_30_3 = "2*((1+$(roundmult(r30_3/100,1e-6)/2))/2))^{2*3.0}/(1+$(r25_3/100)/2)^{2*2.5} -1)"
	strf30_35_3 = "2*((1+$(roundmult(r35_3/100,1e-6)/2))/2))^{2*3.5}/(1+$(r30_3/100)/2)^{2*3.0} -1)"
	strf35_40_3 = "2*((1+$(roundmult(r40_3/100,1e-6)/2))/2))^{2*4.0}/(1+$(r35_3/100)/2)^{2*3.5} -1)"
	strf40_45_3 = "2*((1+$(roundmult(r45_3/100,1e-6)/2))/2))^{2*4.5}/(1+$(r40_3/100)/2)^{2*4.0} -1)"
	strf45_50_3 = "2*((1+$(roundmult(r50_3/100,1e-6)/2))/2))^{2*5.0}/(1+$(r45_3/100)/2)^{2*4.5} -1)"
	strfVec_3 = [strf05_10_3,strf10_15_3,strf15_20_3,strf20_25_3,strf25_30_3,strf30_35_3,strf35_40_3,strf40_45_3,strf45_50_3]
	display("")	
end

# ╔═╡ d3990ef6-36e4-4d0c-9dcb-e04a2985ed0c
md"""
##
"""

# ╔═╡ a215c5e2-151e-46e8-95d5-bc6ca075d955
Markdown.parse("
Forward Rate   | Value                                     
--------------:|------------------------------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_3*100,1e-4))\\%``   
``f(1.0,1.5)``  | ``$(roundmult(f10_15_3*100,1e-4))\\%``   
``f(1.5,2.0)``  | ``$(roundmult(f15_20_3*100,1e-4))\\%``   
``f(2.0,2.5)``  | ``$(roundmult(f20_25_3*100,1e-4))\\%``   
``f(2.5,3.0)``  | ``$(roundmult(f25_30_3*100,1e-4))\\%``   
``f(3.0,3.5)``  | ``$(roundmult(f30_35_3*100,1e-4))\\%``   
``f(3.5,4.0)``  | ``$(roundmult(f35_40_3*100,1e-4))\\%``   
``f(4.0,4.5)``  | ``$(roundmult(f40_45_3*100,1e-4))\\%``   
``f(4.5,5.0)``  | ``$(roundmult(f45_50_3*100,1e-4))\\%``   

")

# ╔═╡ 85e21ae7-2b70-4b90-a4ed-98af9e641b56
begin
	let
		tVec_3 = collect(0.5:0.5:4.5)
		plot(tVec_3, fVec_3.*100,label="f(t,t+0.5)",title="6-month Forward Rates",xlabel="Time [years]",ylabel="Percent",xlim=[0,5],ylim=[0,15],yticks=0:2.5:15)
		plot!(vcat(0,tVec_3), rVec_3, label="r(t)")

	end
end

# ╔═╡ 26305cf4-2eb0-4a47-a930-632e7b3d5207
md"""
##
"""

# ╔═╡ 86dcdea4-b1ce-4fb9-b006-9089297bf9e0
md"""
- **Downward-Sloping Yield Curve**
"""

# ╔═╡ cb75eaba-01d8-4fe9-b2f0-45f979cfe8ae
@bind bttn_4 Button("Reset")

# ╔═╡ c13d0b72-5b72-46db-9971-eeb1cc6aef5c
begin
bttn_4
	md"""
	- 0.5-year spot rate $r_{0.5}$ [%]: $(@bind r05_4 Slider(0:0.10:10, default=3, show_value=true))
	- 1.0-year spot rate $r_{1.0}$ [%]: $(@bind r10_4 Slider(0:0.10:10, default=2.9, show_value=true))
	- 1.5-year spot rate $r_{1.5}$ [%]: $(@bind r15_4 Slider(0:0.10:10, default=2.8, show_value=true))
	- 2.0-year spot rate $r_{2.0}$ [%]: $(@bind r20_4 Slider(0:0.10:10, default=2.7, show_value=true))
	- 2.5-year spot rate $r_{2.5}$ [%]: $(@bind r25_4 Slider(0:0.10:10, default=2.6, show_value=true))
	- 3.0-year spot rate $r_{3.0}$ [%]: $(@bind r30_4 Slider(0:0.10:10, default=2.5, show_value=true))
	- 3.5-year spot rate $r_{3.5}$ [%]: $(@bind r35_4 Slider(0:0.10:10, default=2.4, show_value=true))
	- 4.0-year spot rate $r_{4.0}$ [%]: $(@bind r40_4 Slider(0:0.10:10, default=2.3, show_value=true))
	- 4.5-year spot rate $r_{4.5}$ [%]: $(@bind r45_4 Slider(0:0.10:10, default=2.2, show_value=true))
	- 5.0-year spot rate $r_{5.0}$ [%]: $(@bind r50_4 Slider(0:0.10:10, default=2.1, show_value=true))

	"""
end

# ╔═╡ 27dff571-a4c1-4eef-b2ee-6fa27e55cf5e
md"""
##
"""

# ╔═╡ 25b02eea-788b-400d-8d92-22698f1aa5f9
begin
	rVec_4 = [r05_4,r10_4,r15_4,r20_4,r25_4,r30_4,r35_4,r40_4,r45_4,r50_4]
	
	f05_10_4 = 2*((1+r10_4/200)^(2*1.0)/(1+r05_4/200)^(2*0.5) -1)
	f10_15_4 = 2*((1+r15_4/200)^(2*1.5)/(1+r10_4/200)^(2*1.0) -1)
	f15_20_4 = 2*((1+r20_4/200)^(2*2.0)/(1+r15_4/200)^(2*1.5) -1)
	f20_25_4 = 2*((1+r25_4/200)^(2*2.5)/(1+r20_4/200)^(2*2.0) -1)
	f25_30_4 = 2*((1+r30_4/200)^(2*3.0)/(1+r25_4/200)^(2*2.5) -1)
	f30_35_4 = 2*((1+r35_4/200)^(2*3.5)/(1+r30_4/200)^(2*3.0) -1)
	f35_40_4 = 2*((1+r40_4/200)^(2*4.0)/(1+r35_4/200)^(2*3.5) -1)
	f40_45_4 = 2*((1+r45_4/200)^(2*4.5)/(1+r40_4/200)^(2*4.0) -1)
	f45_50_4 = 2*((1+r50_4/200)^(2*5.0)/(1+r45_4/200)^(2*4.5) -1)
	fVec_4 = [f05_10_4,f10_15_4,f15_20_4,f20_25_4,f25_30_4,f30_35_4,f35_40_4,f40_45_4,f45_50_4]

	f01_40_4 = (((1+r30_4/200)^(2*3)/(1+r10_4/200)^(2*1))^(1/(2*2))-1)*2
	
	strf05_10_4 = "2*((1+$(roundmult(r10_4/100,1e-6)/2))^{2*1.0}/(1+$(r05_4/100)/2)^{2*0.5} -1)"
	strf10_15_4 = "2*((1+$(roundmult(r15_4/100,1e-6)/2))/2))^{2*1.5}/(1+$(r10_4/100)/2)^{2*1.0} -1)"
	strf15_20_4 = "2*((1+$(roundmult(r20_4/100,1e-6)/2))/2))^{2*2.0}/(1+$(r15_4/100)/2)^{2*1.5} -1)"
	strf20_25_4 = "2*((1+$(roundmult(r25_4/100,1e-6)/2))/2))^{2*2.5}/(1+$(r20_4/100)/2)^{2*2.0} -1)"
	strf25_30_4 = "2*((1+$(roundmult(r30_4/100,1e-6)/2))/2))^{2*3.0}/(1+$(r25_4/100)/2)^{2*2.5} -1)"
	strf30_35_4 = "2*((1+$(roundmult(r35_4/100,1e-6)/2))/2))^{2*3.5}/(1+$(r30_4/100)/2)^{2*3.0} -1)"
	strf35_40_4 = "2*((1+$(roundmult(r40_4/100,1e-6)/2))/2))^{2*4.0}/(1+$(r35_4/100)/2)^{2*3.5} -1)"
	strf40_45_4 = "2*((1+$(roundmult(r45_4/100,1e-6)/2))/2))^{2*4.5}/(1+$(r40_4/100)/2)^{2*4.0} -1)"
	strf45_50_4 = "2*((1+$(roundmult(r50_4/100,1e-6)/2))/2))^{2*5.0}/(1+$(r45_4/100)/2)^{2*4.5} -1)"
	strfVec_4 = [strf05_10_4,strf10_15_4,strf15_20_4,strf20_25_4,strf25_30_4,strf30_35_4,strf35_40_4,strf40_45_4,strf45_50_4]
	display("")	
end

# ╔═╡ a003095e-eb6c-43fc-b133-db7c54678ce9
Markdown.parse("
Forward Rate   | Value                                     
--------------:|------------------------------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_4*100,1e-4))\\%``   
``f(1.0,1.5)``  | ``$(roundmult(f10_15_4*100,1e-4))\\%``   
``f(1.5,2.0)``  | ``$(roundmult(f15_20_4*100,1e-4))\\%``   
``f(2.0,2.5)``  | ``$(roundmult(f20_25_4*100,1e-4))\\%``   
``f(2.5,3.0)``  | ``$(roundmult(f25_30_4*100,1e-4))\\%``   
``f(3.0,3.5)``  | ``$(roundmult(f30_35_4*100,1e-4))\\%``   
``f(3.5,4.0)``  | ``$(roundmult(f35_40_4*100,1e-4))\\%``   
``f(4.0,4.5)``  | ``$(roundmult(f40_45_4*100,1e-4))\\%``   
``f(4.5,5.0)``  | ``$(roundmult(f45_50_4*100,1e-4))\\%``   
")

# ╔═╡ f7ad3000-6bb1-4d1c-899d-94837cc88f38
begin
	let
		tVec_4 = collect(0.5:0.5:4.5)
		plot(tVec_4, fVec_4.*100,label="f(t,t+0.5)",title="6-month Forward Rates",xlabel="Time [years]",ylabel="Percent",xlim=[0,5],ylim=[0,15],yticks=0:2.5:15)
		plot!(vcat(0,tVec_4), rVec_4, label="r(t)")

	end
end

# ╔═╡ e3dab398-f464-4055-ac69-79b6563c999d
md"""
##
"""

# ╔═╡ 5ee68a48-5399-4a1f-90ee-54441ffd3b10
md"""
- **Flat Yield Curve**
"""

# ╔═╡ 4287a1d2-a1df-4de8-bacb-0327e3af9be1
@bind bttn_5 Button("Reset")

# ╔═╡ 1db0b2c4-044f-4d0c-98fe-fdf64d434eb6
begin
bttn_5
	md"""
	- 0.5-year spot rate $r_{0.5}$ [%]: $(@bind r05_5 Slider(0:0.10:10, default=3, show_value=true))
	- 1.0-year spot rate $r_{1.0}$ [%]: $(@bind r10_5 Slider(0:0.10:10, default=3, show_value=true))
	- 1.5-year spot rate $r_{1.5}$ [%]: $(@bind r15_5 Slider(0:0.10:10, default=3, show_value=true))
	- 2.0-year spot rate $r_{2.0}$ [%]: $(@bind r20_5 Slider(0:0.10:10, default=3, show_value=true))
	- 2.5-year spot rate $r_{2.5}$ [%]: $(@bind r25_5 Slider(0:0.10:10, default=3, show_value=true))
	- 3.0-year spot rate $r_{3.0}$ [%]: $(@bind r30_5 Slider(0:0.10:10, default=3, show_value=true))
	- 3.5-year spot rate $r_{3.5}$ [%]: $(@bind r35_5 Slider(0:0.10:10, default=3, show_value=true))
	- 4.0-year spot rate $r_{4.0}$ [%]: $(@bind r40_5 Slider(0:0.10:10, default=3, show_value=true))
	- 4.5-year spot rate $r_{4.5}$ [%]: $(@bind r45_5 Slider(0:0.10:10, default=3, show_value=true))
	- 5.0-year spot rate $r_{5.0}$ [%]: $(@bind r50_5 Slider(0:0.10:10, default=3, show_value=true))

	"""
end

# ╔═╡ eb301928-409e-403c-bd1f-90280c0acb3f
md"""
##
"""

# ╔═╡ f7ac90fc-ac84-4d86-badd-d23a643b7f04
begin
	rVec_5 = [r05_5,r10_5,r15_5,r20_5,r25_5,r30_5,r35_5,r40_5,r45_5,r50_5]
	
	f05_10_5 = 2*((1+r10_5/200)^(2*1.0)/(1+r05_5/200)^(2*0.5) -1)
	f10_15_5 = 2*((1+r15_5/200)^(2*1.5)/(1+r10_5/200)^(2*1.0) -1)
	f15_20_5 = 2*((1+r20_5/200)^(2*2.0)/(1+r15_5/200)^(2*1.5) -1)
	f20_25_5 = 2*((1+r25_5/200)^(2*2.5)/(1+r20_5/200)^(2*2.0) -1)
	f25_30_5 = 2*((1+r30_5/200)^(2*3.0)/(1+r25_5/200)^(2*2.5) -1)
	f30_35_5 = 2*((1+r35_5/200)^(2*3.5)/(1+r30_5/200)^(2*3.0) -1)
	f35_40_5 = 2*((1+r40_5/200)^(2*4.0)/(1+r35_5/200)^(2*3.5) -1)
	f40_45_5 = 2*((1+r45_5/200)^(2*4.5)/(1+r40_5/200)^(2*4.0) -1)
	f45_50_5 = 2*((1+r50_5/200)^(2*5.0)/(1+r45_5/200)^(2*4.5) -1)
	fVec_5 = [f05_10_5,f10_15_5,f15_20_5,f20_25_5,f25_30_5,f30_35_5,f35_40_5,f40_45_5,f45_50_5]

	f01_50_5 = (((1+r30_5/200)^(2*3)/(1+r10_5/200)^(2*1))^(1/(2*2))-1)*2
	
	strf05_10_5 = "2*((1+$(roundmult(r10_5/100,1e-6)/2))^{2*1.0}/(1+$(r05_5/100)/2)^{2*0.5} -1)"
	strf10_15_5 = "2*((1+$(roundmult(r15_5/100,1e-6)/2))/2))^{2*1.5}/(1+$(r10_5/100)/2)^{2*1.0} -1)"
	strf15_20_5 = "2*((1+$(roundmult(r20_5/100,1e-6)/2))/2))^{2*2.0}/(1+$(r15_5/100)/2)^{2*1.5} -1)"
	strf20_25_5 = "2*((1+$(roundmult(r25_5/100,1e-6)/2))/2))^{2*2.5}/(1+$(r20_5/100)/2)^{2*2.0} -1)"
	strf25_30_5 = "2*((1+$(roundmult(r30_5/100,1e-6)/2))/2))^{2*3.0}/(1+$(r25_5/100)/2)^{2*2.5} -1)"
	strf30_35_5 = "2*((1+$(roundmult(r35_5/100,1e-6)/2))/2))^{2*3.5}/(1+$(r30_5/100)/2)^{2*3.0} -1)"
	strf35_40_5 = "2*((1+$(roundmult(r40_5/100,1e-6)/2))/2))^{2*4.0}/(1+$(r35_5/100)/2)^{2*3.5} -1)"
	strf40_45_5 = "2*((1+$(roundmult(r45_5/100,1e-6)/2))/2))^{2*4.5}/(1+$(r40_5/100)/2)^{2*4.0} -1)"
	strf45_50_5 = "2*((1+$(roundmult(r50_5/100,1e-6)/2))/2))^{2*5.0}/(1+$(r45_5/100)/2)^{2*4.5} -1)"
	strfVec_5 = [strf05_10_5,strf10_15_5,strf15_20_5,strf20_25_5,strf25_30_5,strf30_35_5,strf35_40_5,strf40_45_5,strf45_50_5]
	display("")	
end

# ╔═╡ 195323cf-fc08-4b05-823c-5f015512b9c4
Markdown.parse("
Forward Rate   | Value                                     
--------------:|------------------------------------------:
``f(0.5,1.0)``  | ``$(roundmult(f05_10_5*100,1e-4))\\%``   
``f(1.0,1.5)``  | ``$(roundmult(f10_15_5*100,1e-4))\\%``   
``f(1.5,2.0)``  | ``$(roundmult(f15_20_5*100,1e-4))\\%``   
``f(2.0,2.5)``  | ``$(roundmult(f20_25_5*100,1e-4))\\%``   
``f(2.5,3.0)``  | ``$(roundmult(f25_30_5*100,1e-4))\\%``   
``f(3.0,3.5)``  | ``$(roundmult(f30_35_5*100,1e-4))\\%``   
``f(3.5,4.0)``  | ``$(roundmult(f35_40_5*100,1e-4))\\%``   
``f(4.0,4.5)``  | ``$(roundmult(f40_45_5*100,1e-4))\\%``   
``f(4.5,5.0)``  | ``$(roundmult(f45_50_5*100,1e-4))\\%``   
")

# ╔═╡ 3da91d81-c42a-49ee-a182-0a890a182ef3
begin
	let
		tVec_5 = collect(0.5:0.5:4.5)
		plot(tVec_5, fVec_5.*100,label="f(t,t+0.5)",title="6-month Forward Rates",xlabel="Time [years]",ylabel="Percent",xlim=[0,5],ylim=[0,15],yticks=0:2.5:15)
		plot!(vcat(0,tVec_5), rVec_5, label="r(t)")

	end
end

# ╔═╡ 177f3cff-1a43-4f02-a40b-ec6ba38014dc
md"""
# Expectations Hypothesis
"""

# ╔═╡ 4d2e4880-10a7-4ff4-9877-84118414c8da
md"""
- The *Expectations Hypothesis* says that our best estimates of future spot rates come from forward rates.
- For example, the expected six-month spot rate in six-months is equal to today's six-month forward rate 
$$E[r(0.5, 1)] = f(0.5, 1)$$
  - If $f(0.5, 1) > r(0, 0.5)$, then we expect the six-month interest rates to go up.
  - While the theory is intuitive, it is only a partial explanation of the yield curve.
"""

# ╔═╡ 1d3f04f3-a3e4-4dd3-8b7b-c9e351f3c04d
md"""
##
"""

# ╔═╡ d4bf6a32-c541-477d-b67f-f7ff6c5e39e0
LocalResource("Fed_01.png",:width => 1200)

# ╔═╡ 27e59868-e0e6-4ac5-9c20-82f6fb437fc8
md"""
##
"""

# ╔═╡ 80202a12-22eb-4a27-a366-9ed04919828c
LocalResource("Fed_02.png",:width => 900)

# ╔═╡ 9ba810dd-a25d-4e3b-aff3-6eb8c3ebcdc5
md"""
##
"""

# ╔═╡ 5d314581-4b79-4c77-b5de-aba9e16dc010
LocalResource("Fed_03.png",:width => 900)

# ╔═╡ 1836ea4a-2cdf-42ce-a1b4-a9f2f281b02f
md"""
##
"""

# ╔═╡ 44f645fb-7e4d-4471-a6cb-84fda127dae8
LocalResource("Fed_04.png",:width => 900)

# ╔═╡ b1c87fc3-8dd3-4139-b702-3ea6e1c7a650
md"""
##
"""

# ╔═╡ 7e2aa9d1-e9a5-486e-8eef-9885fe6d309f
LocalResource("Fed_05.png",:width => 900)

# ╔═╡ b8d3f830-dbe6-4e05-9045-6a8ddfcfd605
md"""
##
"""

# ╔═╡ ff9b03ce-98ae-4851-bec7-4577f6d8771a
LocalResource("Fed_06.png",:width => 900)

# ╔═╡ 268db708-5c7e-4608-80c0-b8fdb312a26b
md"""
# Forward Contracts
"""

# ╔═╡ fd10c789-7554-4746-873e-8359affc6424
md"""
- So far, we have talked about what are known as *forward rate agreements.*
- In reality, many contracts are **forward contracts**.
- Rather than agreeing on an interest rate, two parties agree on a *future purchase price* that a bond will be purchased at.
- Let $P(T_1,T_2)$ be the price agreed upon today to purchase a bond at time $T_1$. The bond matures at time $T_2$.
- Suppose that $P(0.5, 1) = 98$. 
- This means that we agree today (time 0) to buy a bond at time $T_1=0.5$. The bond matures at time $T_2=1$. The purchase price will be \$98 at time $T_1=0.5$.
"""

# ╔═╡ ee8220b4-92d3-4d0d-ab3d-1a6767a3e2f4
md"""
##
"""

# ╔═╡ 681c1237-2653-4881-a3cd-6e40a18d27f4
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
		Luxor.text("Time t",  Point(-425,0), halign=:left,  valign = :top)
		fontsize(18)
		majticks, minticks = tickline(pt1, pt3,
		    finishnumber=1,
		    major=1, major_tick_function=make_label)
		box.(majticks,1,15,:fill)
		sethue("red")
		Luxor.arrow(pt2, Point(125, -75), Point(200, -75), pt3)
		Luxor.arrow(pt2, pt2 + (0, +75))
		Luxor.arrow(pt3, pt3 + (0, -75))
		label("P(0.5,1.0) = 98", :N, Point(-350,-10), offset=20) 
		label("-98", :N, pt2 + (30,80)) 
		label("+100", :N, pt3 + (0,-80)) 
	end 900 300
	end
end

# ╔═╡ 5dba34fe-2be0-4a2b-8bbd-656083a9ebaf
begin
	T6m_2 = 0.5
	T1y_2 = 1.0
	y6m_2 = 2.0
	y1y_2 = 3.0
	P6m_2 = 100/(1+y6m_2/200)^(2*T6m_2)
	P1y_2 = 100/(1+y1y_2/200)^(2*T1y_2)
	display("")
end

# ╔═╡ ff823d20-7b41-41cf-ac9c-25b375757c16
md"""
##
"""

# ╔═╡ d4d7d04e-537e-464c-9606-1f275b735502
Markdown.parse("
- Suppose we observe the following zero-coupon bonds
Bond        | Time-to-maturity ``T``  |  Price   | Spot Rate
-----------:|----------------------:|---------:|-----------:
X           | ``$(T6m_2)``          | ``$(roundmult(P6m_2,1e-4))`` | ``$(y6m_2)`` %
Z           | ``$(T1y_2)``          | ``$(roundmult(P1y_2,1e-4))`` | ``$(y1y_2)`` %
")

# ╔═╡ b4b2dbfd-758f-4997-854d-dbe4884d6417
md"""
##
"""

# ╔═╡ c09d4a2f-1aff-471b-abed-d6b8c1390dc7
Markdown.parse("
- Suppose we enter into a position of ``x`` units in Bond X and ``z`` units in Bond Z.
Bond        | Units    |  ``t=0``   | ``t=0.5``       |  ``t=1.0``  |
-----------:|---------:|-----------:|----------------:|------------:
X           | ``x``    | ``-$(roundmult(P6m_2,1e-4))\\times x`` | ``100 \\times x`` | 0
Z           | ``z``    | ``-$(roundmult(P1y_2,1e-4))\\times z`` | ``0`` | ``100 \\times z``
Portfolio   |          | 0          |      ?           | 100
")

# ╔═╡ c7a24fbf-372c-4ad2-b9e8-755b22526bc0
md"""
##
"""

# ╔═╡ 5554dd68-fbbc-4102-aee9-dca2a1725c14
Markdown.parse("
- Let's select ``z=1``, i.e. we buy 1 unit of Bond Z.
- To get a zero cash flow at ``t=0`` it must be the case that
``\$-$(roundmult(P6m_2,1e-4)) \\times x -$(roundmult(P1y_2,1e-4)) \\times 1 = 0\$``
``\$x = -\\frac{$(roundmult(P1y_2,1e-4))}{$(roundmult(P6m_2,1e-4))}=$(roundmult(-P1y_2/P6m_2,1e-4))\$``
- Thus, we take a short position in $(roundmult(P1y_2/P6m_2,1e-4)) units of Bond X.
- This creates a cash flow today of
``\$+ P_X \\times $(roundmult(P1y_2/P6m_2,1e-4))=+$(roundmult(P1y_2/P6m_2*P6m_2,1e-4)) \$``
- The resulting cash flows are
")

# ╔═╡ 2d09e624-9ba0-4d14-90c2-af4077e637ea
md"""
##
"""

# ╔═╡ ed5907c4-2e8b-4360-b055-3de9423def27
Markdown.parse("
- Suppose we enter into a position of ``x`` units in Bond X and ``z`` units in Bond Z.
Bond        | Units    |  ``t=0``   | ``t=0.5``       |  ``t=1.0``  |
-----------:|---------:|-----------:|----------------:|------------:
X           | ``x=-$(roundmult(P1y_2/P6m_2,1e-4))``    | ``+$(roundmult(P1y_2/P6m_2*P6m_2,1e-4))`` | ``-$(roundmult(P1y_2/P6m_2*100,1e-4))`` | ``0``
Z           | ``z=1``    | ``-$(roundmult(P1y_2,1e-4))`` | ``0`` | ``100``
Portfolio   |          | ``0``          |      ``-$(roundmult(P1y_2/P6m_2*100,1e-4))``           | ``100``
")

# ╔═╡ ad21b8d3-60c0-413c-b9ae-613e6febb818
md"""
##
"""

# ╔═╡ d6ec176e-1f61-4ca7-9d04-9c4749a304f8
Markdown.parse("
- Thus, the price agreed upon *today* to purchase a bond at time ``T_1=0.5`` that has maturity date at ``T_2=1`` must be
``\$P(0.5,1)= \$$(roundmult(P1y_2/P6m_2*100,1e-4))\$``
")

# ╔═╡ 86b9f9c4-e5f1-4cd2-a68a-702d2ebeca96
md"""
# Pricing Forward Contracts
"""

# ╔═╡ 60d27fdc-4aed-4377-93ae-46abf5bf06b2
md"""
- Thus far, we have calculated the forward price as of today (at time $t=0$).
- Recall that at inception ($t=0$), the value of a forward contract is "fair", i.e. it has a value of zero.
  - Today's cash flow is zero.
- What is the forward price at some time $t>0$ after we entered into the contract?
- As time passes, the value of a forward may become non-zero.
  - Whether a forward rate agreement has a positive or negative value depends on how interest rates have changed since the contract was entered into.
"""

# ╔═╡ 46309d98-4221-4438-9e3b-3d842de61cd6
md"""
##
"""

# ╔═╡ c646af5e-40bc-4098-be50-566cc983048c
begin
	rVec_6 = [2, 3, 3.5, 3, 4, 4.5]
	tVec_6 = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
	fVec_6 = 2 .* ( ((1 .+ rVec_6[2:end] ./ 200).^(2 .* tVec_6[2:end])) ./  ( (1 .+ rVec_6[1:end-1] ./ 200).^(2 .* tVec_6[1:end-1])) .- 1) 	
	display("")	
end

# ╔═╡ d41ba98b-61f8-417b-8377-f12dae4ceb1c
Markdown.parse("
- Suppose that today (``t=0``) is December 31, 2021 and the term structure is as shown below.
Maturity T     |   Maturity Date   |  Spot Rate
--------------:|-------------------|:--------------:
0.5            | June 30, 2022     | 2%
1              | Dec 31, 2022      | 3%
1.5            | June 30, 2023     | 3.5%
2              | Dec 31, 2023      | 3%
2.5            | June 30, 2024     | 4%
3              | Dec 31, 2024      | 4.5%

- Suppose, we enter into a forward rate agreement ``f``(June 2023, Dec 2023) where we agree to invest \$100 at the forward rate for six months starting on June 30, 2023.
- Recall that the forward rate is
``\$f(\\textrm{June 2023}, \\textrm{Dec 2023}) = 2\\times \\left( \\frac{\\left(1+\\frac{r_{2.0}}{2}\\right)^{2\\times 2.0}}{\\left(1+\\frac{r_{1.5}}{2} \\right)^{2\\times 1.5}} -1 \\right) = $(roundmult(fVec_6[3],1e-6))= $(roundmult(fVec_6[3]*100,1e-4))\\%\$``
")

# ╔═╡ fb46eff9-a04e-4629-8e1d-fb0e209b7c54
md"""
##
"""

# ╔═╡ de4bb176-c45e-4ed9-bfd0-eaee95b814ba
Markdown.parse("
- As a concept check, let's verify that the initival value today of the forward rate agreement is indeed zero.
Date      |  Dec 2021 |  June 2022   |   Dec 2022  |  June 2023 |  Dec 2023
---------:|----------:|-------------:|------------:|-----------:|---------:
          | ``t=0``   |  ``t=0.5``   | ``t=1.0``   | ``t=1.5``  | ``t=2``  
          |           |              |             |            |           
Forward   |    0      |      0       |     0       |     -100   |  ``100\\times (1+f_{1.5,2}/2)=$(roundmult(100*(1+fVec_6[3]/2),1e-4))``
")

# ╔═╡ aabf0b08-2ccb-42b1-99f4-6c58d635d9c1
begin
	roundmult(-100/(1+0.035/2)^3+100.7537/(1+0.03/2)^4,1e-4)
	md"""
	- The present value of the forward rate agreement is
	
	$$\frac{-100}{(1+\frac{3.5\%}{2})^{2\times 1.5}}+\frac{100.7537}{(1+\frac{3.0\%}{2})^{2\times 2.0}} = 0$$
	- Thus, the initial value today of the forward rate agreement is indeed zero.
	"""
end

# ╔═╡ ebf95c96-c27d-4c5c-b5e7-73d2ba030d96
md"""
##
"""

# ╔═╡ 9f32bc15-7ee6-4460-ae7d-8675479605aa
begin
	rVec_62 = [2, 2.5, 3.0, 4.0, 5.0]
	tVec_62 = [0.5, 1.0, 1.5, 2.0, 2.5]
	fVec_62 = 2 .* ( ((1 .+ rVec_62[2:end] ./ 200).^(2 .* tVec_62[2:end])) ./  ( (1 .+ rVec_62[1:end-1] ./ 200).^(2 .* tVec_62[1:end-1])) .- 1) 	
	display("")	
end

# ╔═╡ adb7801c-2631-4e55-bc29-dc87b7f47b18
Markdown.parse("
- Suppose now that six months have passed, so that it is now June 30, 2022. 
- Suppose that the term structure is now

Maturity T     |   Maturity Date   |  Spot Rate
--------------:|-------------------|:--------------:
0.5            | Dec 31, 2022      | 2.0%
1.0            | June 30, 2023     | 2.5%
1.5            | Dec 31, 2023      | 3.0%
2.0            | June 30, 2024     | 4.0%
2.5            | Dec 31, 2024      | 5.0%

- What is the forward rate for investing for six months starting in June 2023 now? Let's calculate \$f(\\textrm{June 2023}, \\textrm{Dec 2023})\$.
``\$f(\\textrm{June 2023}, \\textrm{Dec 2023}) = 2\\times \\left( \\frac{\\left(1+\\frac{r_{1.5}}{2}\\right)^{2\\times 1.5}}{\\left(1+\\frac{r_{1.0}}{2} \\right)^{2\\times 1.0}} -1 \\right) = $(roundmult(fVec_6[3],1e-6))= $(roundmult(fVec_62[2]*100,1e-4))\\%\$``
")

# ╔═╡ 3a31fb91-4430-43d0-b076-80dfb185258e
md"""
##
"""

# ╔═╡ f68f63d8-cec5-4edf-baec-a474c3226e7f
Markdown.parse("
- Now, in June 2022, the fair forward rate for investing for six months starting in June 2023 is ``$(roundmult(fVec_62[2]*100,1e-4))\\%``. 
- The fair forward rate that we agreed to when we entered the contract in December 2021 was ``$(roundmult(fVec_6[3]*100,1e-4))\\%``.
- Since the forward rates are different, what is the contract now worth that we entered into in December 2021?
- To answer this question, we calculate the present value of the cash flows from the forward rate agreement that we entered into in December 2021.
")

# ╔═╡ 8fd0267a-9ca9-4327-95ad-a94afb2fecb0
md"""
##
"""

# ╔═╡ 96806e9e-1e77-4ce2-8824-f554d83b3c0a
Markdown.parse("
Date      | June 2022   |   Dec 2022  |  June 2023 |  Dec 2023
---------:|------------:|------------:|-----------:|---------:
          | ``t=0.0``   | ``t=1.5``   | ``t=2.0``  | ``t=2.5``  
          |             |             |            |           
Forward   |     0       |     0       |     -100   |  ``$(roundmult(100*(1+fVec_6[3]/2),1e-4))``
")

# ╔═╡ d979147a-1501-47da-993b-85342938070c
Markdown.parse("
``\$\\textrm{Value of Forward}=\\frac{-100}{\\left(1+\\frac{r_{1.0}}{2}\\right)^{\\times 1.0}} +\\frac{$(roundmult(100*(1+fVec_6[3]/2),1e-4))}{\\left(1+\\frac{r_{1.5}}{2}\\right)^{2\\times 1.5}}=$(roundmult(-100/(1+rVec_62[2]/200)^(2*1)+(100*(1+fVec_6[3]/2))/(1+rVec_62[3]/200)^(2*1.5),1e-4))\$``
")

# ╔═╡ 57284031-f12a-41f9-b8e0-068fca5666e6
md"""
# Eurodollar Futures
"""

# ╔═╡ 60336d7f-a81c-49b3-aa5a-89a485e9de99
md"""
- In practice, most trades are made in the Eurodollar Futures market rather than in forwards.
- Conceptually, there are many similarities between forwards and futures, but there are important differences.

Future               |             Forwards
:--------------------|:----------------------------
- Traded on exchanges with a clearinghouse | - Traded over-the-counter
- Standardized agreements | - Agreements customized between buyer and seller
- Mark-to-market, collateral | - Intended to go to final settlement
"""

# ╔═╡ 34fd31ca-0f88-4266-b00a-8fcc4eb7f566
md"""
##
"""

# ╔═╡ c9c0548e-7c66-425e-ae9c-9c5c31d561e8
md"""
- Eurodollar Futures were introduced by the CME Group in December 1981:
> “... they have often been characterized as the ’Swiss Army knife’ of the futures industry...”
> *Labuszewski and Co.*
"""

# ╔═╡ bd564934-56cb-4c0f-9703-f8a38c309595
md"""
##
"""

# ╔═╡ 9922e3a6-0809-4816-baa5-92a2cb532705
md"""
> “Eurodollar contracts do not appear to have much of a future... Five months after their noisy launch on the Chicago Mercantile Exchange, Eurodollar contracts still haven’t caught on.”
> *Institutional Investor, 1982*
"""

# ╔═╡ 2a468d82-79ec-4152-9a24-9673c7bf925a
md"""
##
"""

# ╔═╡ e4ddd99f-7da3-48d7-a3d7-d364ec262e11
md"""
- Eurodollar Futures Contract
  - Notional size: in units of $1mm
  - March, June, September, and December contracts out 10 years, plus next four months from today
  - Last trading day: Second London bank business day prior to third Wednesday of contract month
  - Final settlement: Cash settlement relative to 3-month LIBOR rather than physical delivery.
"""

# ╔═╡ 1bef76f7-fca0-41e2-952a-d0367b029ef8
md"""
##
"""

# ╔═╡ f2d098fa-ed9b-4e9a-beef-05af02a3aee5
md"""
Prices as of May 28, 2010 (90-day LIBOR deposits) 

Ticker | Expiration | Price  |  Rate (%)
:------|:-----------|:-------|:-----------
EDM0   | 6/14/10    | 99.400 |  0.600 
EDU0   | 9/13/10    | 99.155 |  0.845 
EDZ0   | 12/13/10   | 99.005 | 0.995 
EDH1   | 3/14/11    | 98.875 | 1.125 
EDM1   | 6/13/11    | 98.705 | 1.295 
EDU1   | 9/19/11    | 98.495 | 1.505 
EDZ1   | 12/19/11   | 98.245 | 1.755 
EDH2   | 3/19/12    | 98.010 | 1.990

*Source: Tuckman and Serrat* 

For current futures prices, see [CME Group](http://www.cmegroup.com/trading/interest-rates/stir/eurodollar.html).
"""

# ╔═╡ e486c4db-cd37-4e1e-9cac-68665360bc7c
md"""
##
"""

# ╔═╡ 91908f4b-b069-4890-90c6-28f674af9210
md"""
- Let’s consider the futures contract expiring on 3/19/12.
  - Basically, locking in an interest rate of 1.99% (on an annual basis) for a 90-day investment starting on March 19, 2012.
  - \$1,000,000 invested on March 19 , 2012 
  - \$1,000,000 × (1 + 0.0199 × 90/360) = $1,004,975 on June 17, 2012.
  - Absent the institutional differences, on May 28, 2010, we basically have 
$$f(\textrm{March 19, 2012}, \textrm{June 17, 2012}) = 1.99\%$$
"""

# ╔═╡ 53c77ef1-899d-47c8-8a30-ea38380d1614
md"""
# Wrap-Up
"""

# ╔═╡ 670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
begin
	html"""
	<fieldset>      
        <legend>Our goals for today</legend>      
		<br>
<input type="checkbox" value="" checked>Understand and calculate forward rates.<br><br>
<input type="checkbox" value="" checked>Understand how forward rates and spot rates are connected.<br><br>
<input type="checkbox" value="" checked>Know the Expectation Hypothesis and use it to interpret expectations about Fed Monetary Policy.<br><br>
<input type="checkbox" value="" checked>Understand the relation between forward rates and forward contracts.<br><br>
<input type="checkbox" value="" checked>Value a forward rate agreement.<br><br>
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
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.3.1"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Luxor = "~2.18.0"
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
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

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
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "cfdfef912b7f93e4b848e80b9befdf9e331bc05a"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.1"

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
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

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
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

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
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Luxor]]
deps = ["Base64", "Cairo", "Colors", "Dates", "FFMPEG", "FileIO", "Juno", "Random", "Rsvg"]
git-tree-sha1 = "6d663c668fd508e55889195f51bb13a442e951a7"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "2.18.0"

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
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

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
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

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
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7eda8e2a61e35b7f553172ef3d9eaa5e4e76d92e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.3"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

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

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

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
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

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
git-tree-sha1 = "244586bc07462d22aed0113af9c731f2a518c93e"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.10"

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
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

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
# ╟─f78f3c79-46e0-42d1-93a3-91cbd7ccb371
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─61887938-ec20-45c9-8ab8-b812fefcda3c
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─d1b0ba85-b06b-4f01-af36-4c6f61e72607
# ╟─e0bd6de3-325d-4684-a371-d6957f96f664
# ╟─ae82f174-51f0-40f6-a85b-68b2cc188e9f
# ╟─1fcd390e-8fb7-442c-bba9-f229b89fd2e8
# ╟─e10efd0c-a0e1-400d-873b-0ba958ee49f5
# ╟─219ee1eb-84a9-44ed-8081-6da40084dc93
# ╟─ec964651-e7b7-48d9-a93e-9563c948890f
# ╟─17341757-a1dd-4ab1-873f-f091bad5941d
# ╟─5924f10c-b93a-433c-86a6-9adf5950e168
# ╟─c4b7668d-2e0c-4029-a8ab-52259d680b8a
# ╟─b3a2664f-c62a-4ab2-8d4a-90713a01175f
# ╟─a64e70ba-4d8e-4c60-a381-986bb4956ed7
# ╟─8575019d-63f4-4c61-b3fd-748ff312f6f6
# ╟─5eb248a3-1521-4f77-88bc-2b35275d3104
# ╟─75f9e75d-13a3-4efb-b2dc-9fda809c6eb0
# ╟─cb8cf80b-e800-4fc9-a07d-21032cbc107b
# ╟─25aa5bec-668c-45fd-a820-18862d0052a8
# ╟─b531c923-f0b9-4830-be89-c22bea11c6d1
# ╟─56800364-65bc-4071-8692-8989d903b412
# ╟─e61dc458-0d56-4f93-aa3c-a01729f45c80
# ╟─7a2318b5-77aa-41c4-8076-9052dfe40894
# ╟─42461a91-61cf-426c-a950-c7084a1f132e
# ╟─3c6ba609-b316-4082-8c75-9b5da8928bc2
# ╟─e9cb4d2d-1e50-4f86-a8ad-d4e09649cdb0
# ╟─0b40db04-f458-4843-a5af-2eb23602fbc0
# ╟─f99ac143-0216-4ed5-9c4a-774161e62334
# ╟─0099b4ec-061d-4370-ac30-34339a66b5ce
# ╟─3f3825d1-6ac8-4608-9cb7-77e758f625e4
# ╟─cdfe0473-9a2b-4310-804e-f497e68f3471
# ╟─b62e3e14-e3fa-4ae0-acdd-aced322a5432
# ╟─90be5edd-4515-47bb-bf12-26dd492afa6e
# ╟─cb7238f5-5f98-4bd1-b973-e4614832d2d7
# ╟─33110efa-f7d7-410a-a170-b0ba8bc1da27
# ╟─faad21f6-2ee1-47ab-b503-1e6b6f51c21e
# ╟─844183ad-f5a6-4735-bae1-0592aeafe398
# ╟─298aac39-e42e-409b-9642-944531ac216d
# ╟─15c836cb-fbe4-4494-9b92-20001d882664
# ╟─73a9d891-75ea-480e-98b1-5e73493c61c7
# ╟─33931907-e196-4325-9c8e-d2ed9a21d49f
# ╟─1243c98c-d0d7-408d-bc4e-849552fa5305
# ╟─fd3922c6-d5a2-4124-b74f-6cffc6a529cd
# ╟─8e83dcfb-970f-40ec-a1e0-a82c68f64964
# ╟─235135fe-bc62-46d0-9a7c-a2a0458e0de1
# ╟─01af2967-477b-44fe-a479-0ab5accd4a2f
# ╟─bebe1514-2120-4d5c-9245-a0310dd8622a
# ╟─9c3498c4-3aa6-4c65-853b-f13333295485
# ╟─91691be0-c0f8-4ae7-b5e7-6ecb044abf03
# ╟─1939288d-5e24-43a0-b5c7-d7c6bd202524
# ╟─16777168-522f-469b-a1e1-566d7a2b8204
# ╟─acda8937-b591-4599-840b-34cd0267339b
# ╟─afa00268-983f-4960-a93c-0135e7081e27
# ╟─f07c5a3d-d943-458c-abfb-4a57b879f4a6
# ╟─24646b27-e765-4340-aec1-b45295d14644
# ╟─95c45360-da9e-4bb6-894d-70b0a1a85b42
# ╟─15272a5f-dcef-4ee6-8ab1-30479a627bf6
# ╟─753ae53b-fcf8-4085-af43-c77229ff1704
# ╟─d6db6b29-60f4-45d7-8015-8c93d8dae7e7
# ╟─aac995ac-95d3-4e4f-a3df-27e18f740386
# ╟─6a723abc-8040-4355-9c64-82d05d9e8275
# ╟─ee8cb6db-e002-41f6-8c71-aae043041dcf
# ╟─7badc2ed-da19-4286-92b1-10279b0ffcb1
# ╟─7bb03222-7f16-4cb7-96fc-647c57447309
# ╟─8cec18c4-f464-46ef-85e9-7ad4e059b973
# ╟─d138271f-88d4-42eb-853d-9443d353ab32
# ╟─e64ee014-0971-4162-8869-04f71228a7f1
# ╟─c8f89c41-19e5-4fc9-ab30-08c0d669ad43
# ╟─b3e89143-09cb-4274-8a5a-26c3a17cfe84
# ╟─94bb4997-c2ad-4803-8181-dfe824f9019a
# ╟─5ab35e41-d016-4919-820e-80f572e7a1ea
# ╟─50e93557-f381-4d56-915b-b76197dab0e0
# ╟─e980cabe-4924-4232-be56-1192ec21e30e
# ╟─dd5360b3-a49f-4ded-99aa-b2cbd475a8ca
# ╟─ffec6b06-f96f-423c-82c6-40a78b7e8d0f
# ╟─a2d3945a-1be0-4710-8207-ed78f0d28a5a
# ╟─7227f1f8-83f3-411b-9f24-e28dfda6e4f9
# ╟─07b764cb-2ced-462a-88b5-a409a9c83775
# ╟─fa7c6f7d-0752-4c73-8485-c7e3305ad0c2
# ╟─095bd350-7631-4f58-ac07-690d20a2a115
# ╟─fd82b88e-bd1a-419e-8ea3-87846e7ec859
# ╟─dc2ccb67-79f1-4143-9d7b-f3b391c9f723
# ╟─af1bbcd8-280d-409e-bf27-43809ebbff2f
# ╟─db6ae21f-9f39-4555-ae90-eeec9e8ab318
# ╟─f3ac8072-17ca-4def-8a3f-8c72a26dfe07
# ╟─c6f4c700-1c97-4927-bd86-b95013e5ebbf
# ╟─15d63080-7bae-405e-96da-4a45a7601d6e
# ╟─3d629b93-178b-48d9-83c4-e39529dd0255
# ╟─34e8fe6c-ba82-425b-b31c-d3d9319af6f2
# ╟─992f5676-c5f3-440a-b673-213bf4a9ca20
# ╟─48081c8f-234a-4f93-a142-594584a28653
# ╟─0f59ed23-a2c2-4495-a10d-0c49b40de3dc
# ╟─2eb91aff-402d-4f3d-aad1-d0634e77de22
# ╟─d3990ef6-36e4-4d0c-9dcb-e04a2985ed0c
# ╟─a215c5e2-151e-46e8-95d5-bc6ca075d955
# ╟─85e21ae7-2b70-4b90-a4ed-98af9e641b56
# ╟─26305cf4-2eb0-4a47-a930-632e7b3d5207
# ╟─86dcdea4-b1ce-4fb9-b006-9089297bf9e0
# ╟─c13d0b72-5b72-46db-9971-eeb1cc6aef5c
# ╟─cb75eaba-01d8-4fe9-b2f0-45f979cfe8ae
# ╟─27dff571-a4c1-4eef-b2ee-6fa27e55cf5e
# ╟─25b02eea-788b-400d-8d92-22698f1aa5f9
# ╟─a003095e-eb6c-43fc-b133-db7c54678ce9
# ╟─f7ad3000-6bb1-4d1c-899d-94837cc88f38
# ╟─e3dab398-f464-4055-ac69-79b6563c999d
# ╟─5ee68a48-5399-4a1f-90ee-54441ffd3b10
# ╟─4287a1d2-a1df-4de8-bacb-0327e3af9be1
# ╟─1db0b2c4-044f-4d0c-98fe-fdf64d434eb6
# ╟─eb301928-409e-403c-bd1f-90280c0acb3f
# ╟─f7ac90fc-ac84-4d86-badd-d23a643b7f04
# ╟─195323cf-fc08-4b05-823c-5f015512b9c4
# ╟─3da91d81-c42a-49ee-a182-0a890a182ef3
# ╟─177f3cff-1a43-4f02-a40b-ec6ba38014dc
# ╟─4d2e4880-10a7-4ff4-9877-84118414c8da
# ╟─1d3f04f3-a3e4-4dd3-8b7b-c9e351f3c04d
# ╟─d4bf6a32-c541-477d-b67f-f7ff6c5e39e0
# ╟─27e59868-e0e6-4ac5-9c20-82f6fb437fc8
# ╟─80202a12-22eb-4a27-a366-9ed04919828c
# ╟─9ba810dd-a25d-4e3b-aff3-6eb8c3ebcdc5
# ╟─5d314581-4b79-4c77-b5de-aba9e16dc010
# ╟─1836ea4a-2cdf-42ce-a1b4-a9f2f281b02f
# ╟─44f645fb-7e4d-4471-a6cb-84fda127dae8
# ╟─b1c87fc3-8dd3-4139-b702-3ea6e1c7a650
# ╟─7e2aa9d1-e9a5-486e-8eef-9885fe6d309f
# ╟─b8d3f830-dbe6-4e05-9045-6a8ddfcfd605
# ╟─ff9b03ce-98ae-4851-bec7-4577f6d8771a
# ╟─268db708-5c7e-4608-80c0-b8fdb312a26b
# ╟─fd10c789-7554-4746-873e-8359affc6424
# ╟─ee8220b4-92d3-4d0d-ab3d-1a6767a3e2f4
# ╟─681c1237-2653-4881-a3cd-6e40a18d27f4
# ╟─5dba34fe-2be0-4a2b-8bbd-656083a9ebaf
# ╟─ff823d20-7b41-41cf-ac9c-25b375757c16
# ╟─d4d7d04e-537e-464c-9606-1f275b735502
# ╟─b4b2dbfd-758f-4997-854d-dbe4884d6417
# ╟─c09d4a2f-1aff-471b-abed-d6b8c1390dc7
# ╟─c7a24fbf-372c-4ad2-b9e8-755b22526bc0
# ╟─5554dd68-fbbc-4102-aee9-dca2a1725c14
# ╟─2d09e624-9ba0-4d14-90c2-af4077e637ea
# ╟─ed5907c4-2e8b-4360-b055-3de9423def27
# ╟─ad21b8d3-60c0-413c-b9ae-613e6febb818
# ╟─d6ec176e-1f61-4ca7-9d04-9c4749a304f8
# ╟─86b9f9c4-e5f1-4cd2-a68a-702d2ebeca96
# ╟─60d27fdc-4aed-4377-93ae-46abf5bf06b2
# ╟─46309d98-4221-4438-9e3b-3d842de61cd6
# ╟─d41ba98b-61f8-417b-8377-f12dae4ceb1c
# ╟─c646af5e-40bc-4098-be50-566cc983048c
# ╟─fb46eff9-a04e-4629-8e1d-fb0e209b7c54
# ╟─de4bb176-c45e-4ed9-bfd0-eaee95b814ba
# ╟─aabf0b08-2ccb-42b1-99f4-6c58d635d9c1
# ╟─ebf95c96-c27d-4c5c-b5e7-73d2ba030d96
# ╟─adb7801c-2631-4e55-bc29-dc87b7f47b18
# ╟─9f32bc15-7ee6-4460-ae7d-8675479605aa
# ╟─3a31fb91-4430-43d0-b076-80dfb185258e
# ╟─f68f63d8-cec5-4edf-baec-a474c3226e7f
# ╟─8fd0267a-9ca9-4327-95ad-a94afb2fecb0
# ╟─96806e9e-1e77-4ce2-8824-f554d83b3c0a
# ╟─d979147a-1501-47da-993b-85342938070c
# ╟─57284031-f12a-41f9-b8e0-068fca5666e6
# ╟─60336d7f-a81c-49b3-aa5a-89a485e9de99
# ╟─34fd31ca-0f88-4266-b00a-8fcc4eb7f566
# ╟─c9c0548e-7c66-425e-ae9c-9c5c31d561e8
# ╟─bd564934-56cb-4c0f-9703-f8a38c309595
# ╟─9922e3a6-0809-4816-baa5-92a2cb532705
# ╟─2a468d82-79ec-4152-9a24-9673c7bf925a
# ╟─e4ddd99f-7da3-48d7-a3d7-d364ec262e11
# ╟─1bef76f7-fca0-41e2-952a-d0367b029ef8
# ╟─f2d098fa-ed9b-4e9a-beef-05af02a3aee5
# ╟─e486c4db-cd37-4e1e-9cac-68665360bc7c
# ╟─91908f4b-b069-4890-90c6-28f674af9210
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
