### A Pluto.jl notebook ###
# v0.17.3

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

# ╔═╡ d160a115-56ed-4598-998e-255b82ec37f9
#Set-up packages
begin
	
	using DataFrames, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, Statistics, XLSX
	
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

	display("")
end

# ╔═╡ 41d7b190-2a14-11ec-2469-7977eac40f12
#add button to trigger presentation mode
html"<button onclick='present()'>present</button>"

# ╔═╡ 731c88b4-7daf-480d-b163-7003a5fbd41f
begin 
	html"""
	<p align=left style="font-size:36px; font-family:family:Georgia"> <b> FINC 462/662 - Fixed Income Securities</b> <p>
	"""
end

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Measures of Bond Price Volatility
	</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.05cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0cm"> </p>
	"""
end

# ╔═╡ 3eeb383c-7e46-46c9-8786-ab924b475d45
begin
 function getBondPrice(y,c,T,F)
	dt = collect(0.5:0.5:T)
	C = (c/200)*F
	CF = C.*ones(length(dt))
	CF[end] = F+C
	PV = CF./(1+y/200).^(2 .* dt)
	return sum(PV)
 end

 function getModDuration(y,c,T,F)
	P0 = getBondPrice(y,c,T,F)
	deltaY = 0.10 
	Pplus  = getBondPrice(y+deltaY,c,T,F)
	Pminus = getBondPrice(y-deltaY,c,T,F)
	return -(Pplus-Pminus)./(2 * deltaY * P0)
 end
 display("")
	
end

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
<input type="checkbox" value="">Understand why we use Convexity and how to calculate it.<br><br>
<input type="checkbox" value="">Calculate the Convexity Convexity of a portfolio.<br><br>
<input type="checkbox" value="">Use Modified Duration to hedge interest rate risk.<br><br>
<input type="checkbox" value="">Use Modified Duration and Convexity to hedge interest rate risk.<br><br>
</fieldset>      
	"""
end

# ╔═╡ c937d82d-eafe-4940-a69f-b76a2313fb6b
TableOfContents(aside=true, depth=1)

# ╔═╡ 51ff9016-8ec3-406d-aed5-dc68f0cdd910
md"""
# Modified Duration and the Price-Yield Relation
"""

# ╔═╡ f07c5a3d-d943-458c-abfb-4a57b879f4a6
@bind bttn_1 Button("Reset")

# ╔═╡ acda8937-b591-4599-840b-34cd0267339b
begin
bttn_1
	md"""
	- Face Value $F$ [$]: $(@bind F1 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c1 Slider(0:0.125:10, default=2, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T1 Slider(0:1:50,default=30,show_value=true))
	"""
end

# ╔═╡ 86fe4f73-50bb-4ea1-b27f-503e65c3d4d9
begin
	C1 = c1/200 * F1
	yvec1 = collect(1:0.1:10)
	P1vec = zeros(length(yvec1))
	for idx=1:length(yvec1)
		P1vec[idx] = (C1/(yvec1[idx]/200)) * (1 - 1/(1+(yvec1[idx]/200))^(2*T1)) + 100/(1+yvec1[idx]/200)^(2*T1)
	end
	p1_5 = getBondPrice(5,c1,T1,F1)
	md1_5 =  getModDuration(5,c1,T1,F1)
	
	plot(yvec1, P1vec, xlim=(yvec1[1],yvec1[end]), xticks=1:1:yvec1[end], ylim=(0, 150),
		fontfamily="Times New Roman", label="Price-Yield Relation P(y)",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :topright, title="Price-Yield Relation")
	
	gradient_line = (x -> p1_5 .- 100 .* md1_5./2 .* (x .- 5))
	plot!(yvec1,gradient_line(yvec1),label="Tangent Line")
	
end

# ╔═╡ 618093a8-60d3-4c2a-b128-c7cc1bd41fd3
md"""
##
"""

# ╔═╡ 08c27c82-a6aa-47ce-ad6a-ead9cc896a36
md"""
- The tangent line approximates the price-yield relation closely near the tangency point. 
- The modified duration can be interpreted as giving us the percent price change of the bond when we assume that the price-yield relation is represented by the tangent line.

"""

# ╔═╡ edfeb23e-0c6e-4b04-a551-2a11ab611dd3
md"""
##
"""

# ╔═╡ ba18ce52-a35d-4039-9b06-3a77c503c0d5
md"""
- Recall that we compute modified duration $MD(y)$ using
$$MD(y) \approx - \frac{P(y+\Delta y)-P(y-\Delta y)}{2\times \Delta y} \times \frac{1}{P(y)}$$
- And recall that we approximate the percent price change of the bond using
$$\frac{\Delta P}{P} = -MD(y) \times \Delta y$$

"""

# ╔═╡ 52faaf0c-da7e-40f5-ab83-7ff78bf0457d
md"""
##
"""

# ╔═╡ 0ef8a1c1-63c6-4ca4-99d3-6279db5887a5
md"""
- We noted, however, that the previous equation becomes inaccurate as yield changes increase.
- We now add a "Convexity" term to this equation that takes into account the convex shape of the price-yield relation.
- This will improve the accuracy of our approximation formula.
"""

# ╔═╡ f19ee8ea-4f86-4a63-9ef8-92f22360e63a
md"""
##
"""

# ╔═╡ df657c50-9546-4e88-b135-a03dd896dfe4
md"""
- Let's first define the **convexity** $\textrm{CX}$ of a standard semi-annual coupon bond with price $P$ time-to-maturity $T$, coupon rate $c$ (paid-semiannually), semi-annual coupon cash flows of $C$, face value $F$ and yield-to-maturity of $y$ (semi-annually compounded).

"""

# ╔═╡ 1c5d11a2-6f90-4f6a-b99a-1e4457442f8b
md"""
##
"""

# ╔═╡ 29d5d4f7-904e-44e7-8a60-e5543b48008d
md"""
- To shorten the notation, we will 
  - use $n=1,\ldots,N$ to denote the coupon period.
    - n=1 corresponds to t=0.5 (the first coupon period).
    - The last coupon period $N$ corresponding to $2\times T$.
  - use $Y$ to denote the per-period yield, i.e. $Y=y/2$.
- The **per-period** convexity is given by

$$\textrm{CX} = \frac{1}{P \times (1+Y)^2} \times \sum_{n=1}^{N} \left[ \frac{C}{(1+Y)^n} \left( n^2+n \right) \right]$$

- To get the **annual** convexity we divide $CX$ by the square of the number of periods in each year.
  - For instance, for semi-annual coupon bonds, there are two periods per year. 
  - Thus, we divide $CX$ by $4$ (since $2^2=4$).
"""

# ╔═╡ 7e6c008f-3ced-4cf1-a325-d66fa564a61c
md"""
##
"""

# ╔═╡ eb75afbd-07ed-4732-82d8-3da953d3459e
md"""
- For a zero-coupon bond, the formula simplifies.
- Specifically, for a zero-coupon bond with time-to-maturity $T$ and yield-to-maturity $y$ (**annually compounded**)

$$\textrm{CX} = \frac{T^2+T}{(1+y)^2}$$
"""

# ╔═╡ 14f29db1-3465-4d15-b00f-4cfb81d9d2ac
md"""
##
"""

# ╔═╡ fab999bb-f8dc-44a0-ad8d-f51bc20b646c
md"""
- Instead of using the previous formula, we can use the following to calculate the convexity $\textrm{CX}$.
$$\textrm{CX} = \frac{P(y+\Delta y)+P(y-\Delta y)-2\times P(y)}{(\Delta y)^2} \times \frac{1}{P(y)}$$

- Recall the notation:
  -  $\Delta P$ is the dollar price change of a bond. 
  -  $\frac{\Delta P}{P}$ is the percent change in the price of a bond.
  -  $\Delta y$ is the change in the yield of the bond in decimals.
  -  $P(y)$ is the bond price when the yield-to-maturity is $y$ (keeping time-to-maturity $T$ and coupon rate $c$ fixed).
"""

# ╔═╡ 17e98d7a-6d16-42c8-b127-1b8fd48e2ed3
md"""
##
"""

# ╔═╡ 28d0e6f9-42fd-4122-ae6b-23aa94eb5cb0
md"""
- We can now approximate bond price changes more precisely by using
$$\frac{\Delta P}{P} = -MD(y) \times \Delta y + \frac{1}{2} \times \textrm{CX} \times (\Delta y)^2$$
"""

# ╔═╡ a04b63e4-9c71-406e-b185-a27c7083371a
md"""
## Example
"""

# ╔═╡ 1a0464c0-9112-41de-958a-bc82e44a8b81
@bind bttn_2 Button("Reset")

# ╔═╡ 4615f144-32ed-4dbd-8fcf-7f39b7dfd61a
begin
bttn_2
	md"""
	- Face Value $F$ [$]: $(@bind F2 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c2 Slider(0:0.125:10, default=8, show_value=true))
	- Yield $y$ [% p.a.]: $(@bind y2 Slider(0:0.125:10, default=6, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T2 Slider(0:1:50,default=10,show_value=true))
	"""
end

# ╔═╡ 03fb80a2-8208-4124-8345-aa6c6d88a37d
md"""
##
"""

# ╔═╡ d5de39af-0dfc-4e0d-937c-85bed3cf8737
md"""
##
"""

# ╔═╡ b8f42ad5-26e6-4336-8ea9-a5586b10a910
md"""
##
"""

# ╔═╡ f833d99d-dd8b-42a7-a51d-59291b8a40b2
md"""
##
"""

# ╔═╡ 8d6c5fe2-dac4-40fa-b76a-11253fb501de
md"""
##
"""

# ╔═╡ 431ffd4b-0d7e-4c8c-bb7a-7e8b02916559
md"""
##
"""

# ╔═╡ e2b51a3d-1ea0-47cc-882f-808c82bed745
begin
	C2 = c2/200*F2
	dt2vec = 0.5:0.5:T2
	deltaY2 = 0.2
	y2plus  = y2 + deltaY2
	y2minus = y2 - deltaY2
	C2Vec = C2 .* ones(length(dt2vec))
	C2Vec[end]=F2+C2
	PV2Vec = C2Vec ./ (1 .+ y2/200 ).^(2 .* dt2vec)
	P2 = sum(PV2Vec)

	PV2Vecplus = C2Vec ./ (1 .+ y2plus/200 ).^(2 .* dt2vec)
	P2plus = sum(PV2Vecplus)
	PV2Vecminus = C2Vec ./ (1 .+ y2minus/200 ).^(2 .* dt2vec)
	P2minus = sum(PV2Vecminus)
	MD2 = -(P2plus-P2minus)/(2*deltaY2/100*P2)
	CX2 = (P2plus + P2minus - 2*P2)/(deltaY2/100)^2*1/P2
	display("")
end

# ╔═╡ 24213af7-4c78-4a96-baf6-db05d2087e08
Markdown.parse("
- Consider a semi-annual bond with time-to-maturity ``T=$T2`` years, face value ``F=$F2``, coupon rate ``c=$c2``%, semi-annual coupon cash flows of ``C=$C2`` and yield-to-maturity ``y=$y2``%.
- Calcualte the convexity ``\\textrm{CX}`` of this bond.

``\$\\textrm{CX} = \\frac{P(y+\\Delta y)+P(y-\\Delta y)-2\\times P(y)}{(\\Delta y)^2} \\times \\frac{1}{P(y)}\$``

")

# ╔═╡ 0ac1ccd8-f726-4a95-8978-5069b553e90e
Markdown.parse("
- We start by selecting the yield change ``\\Delta y=$deltaY2``%
- First, we calculate the bond price ``P(y)``
``\$ P(y) = \\frac{C}{y/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2,1e-4))\$``


")

# ╔═╡ 06c2bf78-d5f2-4d8c-be00-1536b7d87546
Markdown.parse("
- Next, using ``\\Delta y=$deltaY2``% 
``\$ P(y+\\Delta y) = \\frac{C}{(y+\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2plus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2plus\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2plus\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2plus,1e-4))\$``


")

# ╔═╡ ef610c94-a085-4ea9-acc8-4436d8b6e3c9
Markdown.parse("
- Similarly,
``\$ P(y-\\Delta y) = \\frac{C}{(y-\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2minus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2minus\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2minus\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2minus,1e-4))\$``

")

# ╔═╡ ed793c92-73ec-4986-923c-76bf79cec892
Markdown.parse("
- Thus,
``\$\\textrm{CX} = \\frac{$(roundmult(P2plus,1e-4))+$(roundmult(P2minus,1e-4))-2\\times $(roundmult(P2,1e-4))}{($(roundmult(deltaY2,1e-4)))^2} \\times \\frac{1}{$(roundmult(P2,1e-4))}=$(roundmult(CX2,1e-6))
\$``

")

# ╔═╡ a3763cba-0366-438e-bc5d-4a5cfdf1f11e
Markdown.parse("
- Recall that the modified duration of the bond is 

``\$MD(y) = - \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{2\\times \\Delta y} \\times \\frac{1}{P(y)}\$``

``\$MD(y) = - \\frac{$(roundmult(P2plus,1e-4))-$(roundmult(P2minus,1e-4))}{2\\times $(roundmult(deltaY2,1e-4))\\%} \\times \\frac{1}{$(roundmult(P2,1e-4))}=$(roundmult(MD2,1e-6))\$``

")

# ╔═╡ 2012d230-29ee-4ce4-a256-58b69c5ebca6
Markdown.parse("
- Thus, when yield increase from ``y=$y2``% to ``y=6.5``%, the approximate percent change in the bond price is
``\$ \\frac{\\Delta P}{P} = -MD(y) \\times \\Delta y + \\frac{1}{2} \\times \\textrm{CX} \\times (\\Delta y)^2\$``

``\$ \\frac{\\Delta P}{P} = $(-roundmult(MD2,1e-6)) \\times 0.005 + \\frac{1}{2} \\times $(roundmult(CX2,1e-6)) \\times (0.005)^2 = $(roundmult(-MD2*0.005+0.5*CX2*0.005^2,1e-6))=$(roundmult(100*(-MD2*0.005+0.5*CX2*0.005^2),1e-4))\\%\$``

")

# ╔═╡ 125e2dde-ea03-4c2c-afed-d03362fd6199
md"""
##
"""

# ╔═╡ a6f5c5ec-3201-43ad-9a1f-e3133bc88e8f
begin

	y3=y2
	c3=c2
	C3=C2
	T3=T2
	F3=F2
	deltaY3=0.20
	p3 = getBondPrice(y3,c3,T3,F3)
	 	 
	y3vec = collect(0.5:0.5:15)
	delta3vec = zeros(length(y3vec))
	MD3vec = zeros(length(y3vec))
	CX3vec = zeros(length(y3vec))
	P3new = zeros(length(y3vec))
	P3MD = zeros(length(y3vec))
	P3CX = zeros(length(y3vec))
	deltaP3vecActual = zeros(length(y3vec))
	deltaP3vecMD = zeros(length(y3vec))
	deltaP3vecCX = zeros(length(y3vec))
	for idx=1:length(MD3vec)
		delta3vec[idx] = y3vec[idx] .- y3
	 	p3plus	= getBondPrice(y3+deltaY3,c3,T3,F3)
	 	p3minus = getBondPrice(y3-deltaY3,c3,T3,F3)
	 	MD3vec[idx] = - (p3plus-p3minus)/(2*(deltaY3/100)*p3)
		CX3vec[idx] = (p3plus+p3minus-2*p3)/((deltaY3/100)^2*p3)
		P3new[idx] = getBondPrice(y3+delta3vec[idx],c3,T3,F3)
		deltaP3vecActual[idx] = P3new[idx]-p3
		deltaP3vecMD[idx] = p3 .* (-MD3vec[idx]*delta3vec[idx]./100)
		deltaP3vecCX[idx] = p3 .* (-MD3vec[idx]*delta3vec[idx]./100 + 0.5*CX3vec[idx]*(delta3vec[idx]./100)^2)
		P3MD[idx] = p3 + deltaP3vecMD[idx]
		P3CX[idx] = p3 + deltaP3vecCX[idx]
	end
	df3 = DataFrame(CurrentYield=y3.*ones(length(y3vec)),NewYield=y3vec, YieldChange=delta3vec,ActualPrice=P3new,MDPrice=P3MD,CXPrice=P3CX,MD_PriceChange=deltaP3vecMD,CX_PriceChange=deltaP3vecCX,ActualPriceChange=deltaP3vecActual)
end

# ╔═╡ 3b40838c-875f-42aa-b915-39ee0e874a77
md"""
##
"""

# ╔═╡ b1d101b3-b832-498e-a421-704bc5312985
begin
	plot(y3vec, P3new, xlim=(y3vec[1],y3vec[end]), xticks=1:1:y3vec[end], ylim=(0, 150),
		fontfamily="Times New Roman", label="Price-Yield Relation P(y)",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :topright, title="Price-Yield Relation", c=:green)
	
	plot!(y3vec,P3MD,label="MD",c=:blue)
	plot!(y3vec,P3CX,label="MD and Convexity", c=:red)
end

# ╔═╡ e00a8ff6-a0f2-45ec-af54-ef8b0541b8ea
md"""
# Convexity of a Bond Portfolio
"""

# ╔═╡ 0306dfe7-a27d-475c-9b13-529f831efbff
md"""
- Thus far, we have considered the case of a single bond and have calculated its convexity.
- When we have a portfolio of bonds, we calculate the convexity of the bond portfolio using the convexities of the individual bonds in the portfolio.

"""

# ╔═╡ 6e40255f-f102-4643-beb5-063a539369b0
md"""
##
"""

# ╔═╡ 5a073f19-2d6e-46d3-a90d-fb4eaa5d8850
md"""
- Specifically, suppose the bond portfolio consists of $B$ bonds. We denote the individual bonds by $b=1,...,B$.
- The portfolio is assumed to consist of $N_b$ units of each bond $b$.
- Each bond is assumed to have a price of $P_b$ per $100 par value. 
- We write the fraction of the position in bond $b$ to the total portfolio value $P_{\textrm{Portfolio}}$ as
$$w_b = \frac{n_b\times P_b}{P_{\textrm{Portfolio}}}$$
- Note that the total value of the bond portfolio is
$$P_{\textrm{Portfolio}} = n_1 \times P_1 + \ldots + n_B \times P_B$$

"""

# ╔═╡ 5ea3d229-56ea-4ba4-b0cb-23f9dd828c96
md"""
##
"""

# ╔═╡ e4d8e509-f60e-4d0b-9418-c155296039b0
md"""
- Then, we calculate the convexity $CX_{\textrm{Portfolio}}$ of the bond portfolio as the weighted average of the convexities of the individual bonds ($CX_i$).
  
$$CX_{\textrm{Portfolio}} = w_1 \times CX_1 + w_2 \times CX_2 + \ldots + w_B \times CX_B$$
"""

# ╔═╡ 5617fb73-7042-4896-9b60-d5aa236faa79
md"""
## Example
- Suppose that you own a portfolio of zero-coupon bonds. All yields are annually compounded. 
- Calculate the convexity of the portfolio.

Bond   |  Maturity     | Yield     | Face value 
:------|:--------------|:----------|:-------------
H      | 1             |  2%       | 40
I      | 2             | 3%        | 40
J      | 3             | 5%        | 40
K      | 4             | 6%        | 40
L      | 5             | 8%        | 1040

"""

# ╔═╡ 9b77fac9-c667-4c48-99dd-ef2f2e726c9e
begin
	matVec4 = [1,2,3,4,5]
	yVec4 = [2,3,5,6,8]
	fVec4 = [40,40,40,40,1040]
	pVec4 = 100 ./ (1 .+ yVec4/100).^matVec4
	nB4 = fVec4./100
	MD4 = matVec4 ./ (1 .+ (yVec4./100) )
	CX4 = (matVec4.^2 .+ matVec4) ./ (1 .+ (yVec4./100) ).^2
	Pb4 = sum((nB4 .* pVec4))
	wB4 = (nB4 .* pVec4) ./ Pb4
	df4 = DataFrame(Bond=["H","I","J","K","L"],Maturity=matVec4,Yield=yVec4,FaceValue=fVec4,PricePer100=pVec4,nB=nB4, CX=CX4, Pb =Pb4, wb=wB4, wB_CX=wB4.*CX4)
	display("")
end

# ╔═╡ 4f604959-9951-4a21-b096-5dcdfae3688f
md"""
##
"""

# ╔═╡ 976c23bb-d905-4f47-9688-aa1da4963d57
md"""
- Let's first calculate the the prices of the zero coupon bonds per \$100 face value.
- Recall, that the price of a $T$-year maturity zero-coupon bond with yield $y_T$ (annually compounded) is given by

$$P_T = \frac{100}{(1+y_T)^T}$$

"""

# ╔═╡ 1af4de6e-c8a3-4248-af7d-0f6a939d01a1
md"""
##
"""

# ╔═╡ 016caaa6-3043-4d9d-92ca-8263eb14e9a5
md"""
- Next, let's calculate the number of units $n_b$ for each bond $b$ in the portfolio.
- The number of bonds is simply the actual face value divided by 100 face value (which we used to calculate the bond price).
  - For instance for bond H, it is \$40/\$100=0.4
"""

# ╔═╡ 9fc68b55-c7c3-4cbc-bbd5-21a132fbd475
md"""
##
"""

# ╔═╡ e7029561-f30a-4ede-a878-245066728b89
md"""
- Next, we calculate the convexities of the zero-coupon bonds.
- Recall that for a zero-coupon bond with time-to-maturity $T$ and yield-to-maturity $y$ (**annually compounded**), the convexity is

$$\textrm{CX} = \frac{T^2+T}{(1+y)^2}$$

- For instance, for bond L it is $MD_5=\frac{(5^2 + 5)}{(1+8\%)^2}=25.720165$
"""

# ╔═╡ d1ffe738-8d2d-48ce-9e15-0d9d14c7612e
md"""
##
"""

# ╔═╡ 316a9264-3b9a-43bc-956f-5a0a2cf2f35d
md"""
- Next, we calculate the total value of the bond portfolio.
- The value of the bond portfolio $P_{\textrm{Portfolio}}$ is the sum of the values of the positions in the individual bonds. The position in bond $b$ is worth the number of units times the bond price, i.e. $n_b \times P_b$.
"""

# ╔═╡ a82d46b0-41c9-45a7-b3be-040ad8b8c31b
md"""
##
"""

# ╔═╡ 08eec6cb-19ab-474a-8dda-6f5cc7572e17
md"""
- Now we can calculate the portfolio weights

$$w_b = \frac{n_b\times P_b}{P_{\textrm{Portfolio}}}$$
"""

# ╔═╡ ffedd329-ea9b-4287-810e-c135cd168eda
md"""
##
"""

# ╔═╡ e53faa81-6620-4191-a021-f4d1f5ab5f4f
md"""
- As the last step, we compute the convexity of the portfolio $CX_{\textrm{Portfolio}}$

$$CX_{\textrm{Portfolio}} = w_1 \times CX_1 + w_2 \times CX_2 + \ldots + w_B \times CX_B$$

"""

# ╔═╡ 4b485dae-2b99-4cbd-b98e-d8766f5aaba9
Markdown.parse("
``\$CX_{\\textrm{Portfolio}} = $(roundmult(df4.wB_CX[1],1e-4)) + $(roundmult(df4.wB_CX[2],1e-4)) + $(roundmult(df4.wB_CX[3],1e-4)) + $(roundmult(df4.wB_CX[4],1e-4)) + $(roundmult(df4.wB_CX[5],1e-4))\$``

``\$CX_{\\textrm{Portfolio}} = $(roundmult(sum(df4.wB_CX),1e-6))\$``
")


# ╔═╡ 7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
md"""
# Hedging Interest Rate Risk
"""

# ╔═╡ 2b77f392-a2c9-4f53-8da5-b98c4f9842aa
md"""
- Consider a bond **portfolio** with modified duration $MD$ and convexity $CX$. Suppose that the portfolio has a current value (price) of $P$.
- We would like to protect the **value** of our portfolio against changes in interest rates.
  - An increase in interest rates typically leads to a drop in value of a long bond portfolio.
"""

# ╔═╡ df1c19c4-8182-4fed-92bf-a14b9e9532ed
md"""
##
"""

# ╔═╡ 87e92bc5-0dbb-4a02-b3d7-32d911bb31cd
md"""
- To illustrate how we can achieve this, recall how we calculate the percentage price change in the value of a bond portfolio, given the portfolio's duration and convexity.

$$\frac{\Delta P}{P}= - MD \times \Delta y + \frac{1}{2} \times CX \times \left( \Delta y \right)^2$$

- In the equation, we want the percentage price change to be zero, because thenour portfolio does not change in value when interest rates change by $\Delta y$.

$$\frac{\Delta P}{P} \stackrel{!}{=}0$$ 

- How can we achieve this?
"""

# ╔═╡ 58e301bc-edf3-4f5e-a9e4-690dacb8b4bf
md"""
##
"""

# ╔═╡ f6114654-5263-4f87-b355-253bf2d5fb56
md"""
- Looking at the right-hand side of the equation for $\frac{\Delta P}{P}$, it must be the case that

$$-MD \times \Delta y + \frac{1}{2} \times CX \times \left( \Delta y \right)^2 \stackrel{!}{=} 0$$
$$\textrm{for \textbf{all }} \Delta y.$$


"""

# ╔═╡ c224f305-d9e9-428b-904b-96d990bbd90c
md"""
##
"""

# ╔═╡ 4fa330f7-5ae5-4320-9662-323447bbf919
md"""
- A straight-forward way to do this is to construct the portfolio in such a way that the modified duration of the portfolio is zero and the convexity of the portfolio is zero.

$$MD \stackrel{!}{=}0$$
$$CX \stackrel{!}{=}0$$

"""

# ╔═╡ ec174135-4162-4660-8a5c-082209c90dfb
md"""
##
"""

# ╔═╡ 3f287e26-573f-4dbd-a79f-b71358363a63
md"""
- To simplify the calculations, let's start by requiring that **only** the modified duration of the bond portfolio be zero.
  - We will consider modified duration and convexity *jointly* later.
"""

# ╔═╡ 0275ce82-a2cf-4961-a2f6-8c2bd3db592c
md"""
# Hedging Interest Rate Risk using Duration
"""

# ╔═╡ f31d870c-27b4-40d0-8327-b80bbb5581eb
begin
	r4 = 4.0 #percent
	F4_1 = 1000
	T4_1 = 10
	T4_2 = 2
	MD4_1 = T4_1/(1+r4/100)
	MD4_2 = T4_2/(1+r4/100)
	P4_1 = F4_1/(1+(r4/100))^T4_1
	P4_2 = F4_1/(1+(r4/100))^T4_2
	display("")
end

# ╔═╡ 90fe35c6-0591-4331-866a-2bf0e46905ff
md"""
##
"""

# ╔═╡ e544a5b0-a1e5-47b6-8418-5c90cdf31ce0
Markdown.parse("
- Suppose that we are a large firm and that we have issued a bond with \$ $(F4_1) par value. The bond is a zero-coupon bond with maturity in $(T4_1) years.
- Suppose that all interest rates are $(r4)%.
")


# ╔═╡ ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
md"""
##
"""

# ╔═╡ 2c361b3b-ec06-433b-8260-f331a085b40d
Markdown.parse("
- Let's first determine what the value of our liability is today.
- Recall that the price of a 10-year zero coupon bond with \$ ``$(F4_1)`` par value when interest rate are ``$(r4)`` % is

``\$P_{$(T4_1)} = \\frac{F}{(1+r)^{$(T4_1)}} = \\frac{$(F4_1)}{(1+$(r4)\\%)^{$(T4_1)}} = $(roundmult(F4_1/(1+(r4/100))^T4_1,1e-4))\$``
- Thus, the present value of what we owe is \$ ``$(roundmult(F4_1/(1+(r4/100))^T4_1,1e-4))``.
")

# ╔═╡ 617a32eb-350f-4fdf-a576-c235b62f74c6
md"""
##
"""

# ╔═╡ 9b0ce3bf-c89d-415f-b6a3-272e9beb3cbb
Markdown.parse("
- By issuing the bond we have created a liability that fluctuates in value as interest rates change. 
    - Note that issuing a bond is similar to taking a short position in the bond.

")

# ╔═╡ c4bdb17f-b949-4966-a019-a831192dbabe
md"""
##
"""

# ╔═╡ 7e32290d-2825-4205-b0dc-1a96ce80dab4
Markdown.parse("
- Specifically, we know that the bond has a modified duration MD of
``\$MD_{$(T4_1)} = \\frac{T}{1+y} = \\frac{$(T4_1)}{1+$(r4)\\%} = $(roundmult(T4_1/(1+r4/100),1e-4))\$``

")

# ╔═╡ fc228fc0-f6fb-45e1-a586-b835a22093ce
md"""
##
"""

# ╔═╡ 0b15d5f0-13ad-45df-a59a-26a39a2cda51
Markdown.parse("
- Recall that this means that when interest rates decrease by 100 basis points, the value of our  liability increases by around ``$(roundmult(T4_1/(1+r4/100),1e-2))`` percent.

``\$\\frac{\\Delta P_{10}}{P_{$(T4_1)}}= - MD_{$(T4_1)} \\times \\Delta y = - $(roundmult(T4_1/(1+r4/100),1e-2)) \\times \\Delta y\$``
")

# ╔═╡ a06b804d-c4b6-463f-b3ba-d7f41e67ec68
md"""
##
"""

# ╔═╡ 0276c4c6-e018-47b6-ae9a-ffdb5e55a7d9
Markdown.parse("
- We want to hedge our exposure to this liability.
- To hedge our exposure, we can buy/sell a $(T4_2)-year zero-coupon bond in the financial market.

")

# ╔═╡ 6232b5c8-6fb0-40b7-b81f-40ab24afdfb3
md"""
##
"""

# ╔═╡ 1152d568-5360-401e-b264-4520c2cf09e5
Markdown.parse("
- Recall that the modified duration of this  $(T4_2)-year zero-coupon bond is
``\$MD_{$(T4_2)} = \\frac{T}{1+y} = \\frac{$(T4_2)}{1+$(r4)\\%} = $(roundmult(T4_2/(1+r4/100),1e-4))\$``

")

# ╔═╡ f9a70ebe-edcf-4af7-ab04-1eef2ecf236e
md"""
##
"""

# ╔═╡ eecf244a-2aa3-4d23-bc19-e22626f39f9e
Markdown.parse("
- This means that when interest rates decrease by 100 basis points, the value the bond *increases* by around $(roundmult(T4_2/(1+r4/100),1e-2)) percent.

``\$\\frac{\\Delta P_{$(T4_2)}}{P_{$(T4_2)}}= - MD_{$(T4_2)} \\times \\Delta y = - $(roundmult(T4_2/(1+r4/100),1e-2)) \\times \\Delta y\$``
")

# ╔═╡ ec469f71-a70c-46bd-bcf7-edae2e17c529
md"""
##
"""

# ╔═╡ c34cab0c-7a1d-4fc6-8ac6-9c873b22c6c5
md"""
- The idea is that we owe more on the liability, when interest rates decrease and the value of the $(T4_2)-year bond 
- Our bond portfolio will then consist of the 10-year liability and the $(T4_2)-year bond.
- Since we consider modified duration only, the percentage price change in the value of our portfolio is


$$\frac{\Delta P}{P}= - MD \times \Delta y$$

- We want $$\frac{\Delta P}{P}$$ to be zero.
"""

# ╔═╡ a68fc8bb-c27a-41c9-af70-1984b473abf8
md"""
##
"""

# ╔═╡ 0602f8d6-9f0d-4f21-b102-f7649bd9f905
Markdown.parse("
- We can visualize our portfolio by thinking about it as a balance sheet where the liability side consists of the bond we have just issued. 
- The asset side will consist of the $(T4_2)-year bond that we will use to hedge the interest rate risk of the bond we have issued. Suppose the market value of our position in the $(T4_2)-year bond is \$ ``x``.
")

# ╔═╡ b23e2704-8981-4796-a191-fb864b96a00e
Markdown.parse("
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
")

# ╔═╡ c81de955-94b2-4033-a01c-99d3cd0c196c
md"""
##
"""

# ╔═╡ 9da87f89-5cd0-4996-9414-bddd8c2cbb2a
Markdown.parse("
- To quantify the interest rate sensitivity of assets and liabilities, let's add the modified durations of the $(T4_2)-year bond and the $(T4_1)-year bond.
- Recall that the modified duration of a zero-coupon bond with time-to-maturity ``T`` is ``MD = T/1+y``.
")

# ╔═╡ 9d4b5920-0304-425a-8c06-0493925f5228
md"""
##
"""

# ╔═╡ 71a8275a-dfb3-425b-8e48-9dfafe6efc01
Markdown.parse("
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
")

# ╔═╡ 3b36971e-98dd-4851-a337-4f1d740d8eb6
md"""
##
"""

# ╔═╡ 6ea25682-d851-4e13-bacd-1ccc5d8bdf80
md"""
- Suppose that yields increase by $\Delta y$. What is the percentage change in the value of assets/liabilities?
"""

# ╔═╡ 729dab93-8ac9-4da2-9ed9-09e5769dec01
md"""
##
"""

# ╔═╡ 837bc716-4e33-430d-89b7-31ae7ba51c4a
md"""
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
"""

# ╔═╡ c233d6c4-794f-491a-a49a-8fd5ffdbcd30
md"""
##
"""

# ╔═╡ d77d4520-b2e5-4d9b-9016-e03405b44ef9
Markdown.parse("
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\frac{\\Delta B_{$(T4_2)}}{B_{$(T4_2)}}=-MD_{$(T4_2)} \\times \\Delta y`` | ``\\frac{\\Delta B_{$(T4_1)}}{B_{$(T4_1)}}=-MD_{$(T4_1)} \\times \\Delta y``
")

# ╔═╡ 7384e263-bf66-4c92-9204-2d4ed0add7a5
md"""
##
"""

# ╔═╡ 47741dde-57ee-42f1-a227-480d3c9e9796
Markdown.parse("
- Suppose that yields increase by ``\\Delta y``. What is the change in *dollar* terms of the value of assets/liabilities?
- The (approximate) change in dollar terms of the value of a bond with ``T``-years to maturity and modified duration ``MD_T`` is
``\$\\Delta B_{T}=B_{T} \\times (-MD_{T}) \\times \\Delta y\$``

")

# ╔═╡ 3f0ef6f2-6b23-4799-9266-a0927e702392
md"""
##
"""

# ╔═╡ a94d61fa-4559-4bb6-86ee-efac87f3cd38
Markdown.parse("
- Using this insight, the balance sheet can be written as
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\Delta B_{$(T4_2)}= B_{$(T4_2)} \\times (-MD_{$(T4_2)}) \\times \\Delta y`` | ``\\Delta B_{$(T4_1)}=B_{$(T4_1)} \\times (-MD_{$(T4_1)}) \\times \\Delta y``
")

# ╔═╡ 86dcff7f-6d25-49ec-8cf3-bd8678887d47
md"""
##
"""

# ╔═╡ ec1ab99d-4cd2-4154-b872-607b7d9d46cb
Markdown.parse("
- Plugging in the values:
  -  ``B_{$(T4_2)}`` is the value in the $(T4_2)-year bond, i.e. `x`.
  -  ``B_{$(T4_1)}`` is the value in the $(T4_1)-year bond, i.e. `$(roundmult(P4_1,1e-4))`.
  -  ``MD_{$(T4_2)}`` = `$(roundmult(MD4_1,1e-4))`
  -  ``MD_{$(T4_1)}`` = `$(roundmult(MD4_2,1e-4))`
")

# ╔═╡ 7d04d258-69a3-477a-b859-27e8a3b93c5e
md"""
##
"""

# ╔═╡ 3245e9f9-c6de-43ab-90c4-e88e5a1bf28b
Markdown.parse("
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\Delta B_{$(T4_2)}= x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y`` | ``\\Delta B_{$(T4_1)}=$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y``
")

# ╔═╡ b15e91a0-03bf-44e5-94ef-f294c4b205f6
md"""
##
"""

# ╔═╡ e97026b3-ec01-44ce-ab7b-21624d2310a2
Markdown.parse("
- Hedging interest rate risk means that the total change in the value of assets and liabilities should be zero 
  - The change in the value of the liability is offset by the change in value of the asset.
")

# ╔═╡ 7474d772-0cb9-45e4-b6a3-7830c216c033
md"""
##
"""

# ╔═╡ f0cb66f5-9b3b-4c5c-9e1b-40e2fbcf0500
Markdown.parse("
- Thus, it must be the case that
``\$x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y \\stackrel{!}{=} $(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y\$``
- This must be true for all ``\\Delta y`` which means that our position on the $(T4_2)-year zero coupon bond ``x`` must be
``\$x = $(roundmult(P4_1,1e-4)) \\times \\frac{(-$(roundmult(MD4_1,1e-4)))}{(-$(roundmult(MD4_2,1e-4)))} = $(roundmult(P4_1*MD4_1/MD4_2,1e-4))\$``
- Thus, we buy \$ ``$(roundmult(P4_1*MD4_1/MD4_2,1e-4))`` of the $(T4_2)-year zero-coupon bond.
")

# ╔═╡ 2c4d1f76-4d9a-4841-b796-d6398dff93f0
md"""
##
"""

# ╔═╡ 367e6030-3028-40a0-9a5e-cac53506f00d
Markdown.parse("
- What is the **face value** of the position in the $(T4_2)-year zero-coupon bond that has a market value of \$ ``$(roundmult(P4_1*MD4_1/MD4_2,1e-4))``?
- Recall that the market value of a zero-coupon bond with face value ``F`` and time-to-maturity ``T`` when the discount rate is ``y`` (annually-compounded) is
``\$P = \\frac{F}{(1+y)^T}\$``
")

# ╔═╡ c0458366-0b9a-49ad-8b58-1f6a94655958
md"""
##
"""

# ╔═╡ 25a6ae4a-9077-45da-be2b-9c98eb005074
Markdown.parse("
- Pluggin in the market value of the $(T4_2)-year bond and solving for the face value ``F``
``\$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4)) = \\frac{F}{(1+$(r4)\\%)^$(T4_2)}\$``
``\$ F= \\\$ $(roundmult(P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2,1e-2))\$``
")

# ╔═╡ 0c984cb2-0844-4526-8b3f-6fbf986de919
md"""
##
"""

# ╔═╡ a5331500-a5f8-404b-87a7-392faec92dd9
Markdown.parse("
- With the hedge, the market value of our assets and liabilities is
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond:  \$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4))  | $(T4_1)-year Bond: \$ $(roundmult(P4_1,1e-4))
 Face value: \\\$ $(roundmult(P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2,1e-2)) | Face value: \\\$ $(roundmult(F4_1,1e-2))
 
")

# ╔═╡ f36d7ef0-0117-4b2d-8649-f09982346139
md"""
##
"""

# ╔═╡ 5fcc1623-4522-455e-ac64-5681aa8895f9
Markdown.parse("
- Let's verify that the hedge works.
- The market value of our portfolio (assets minus liabilities) is ``\$ \\\$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4)) - \\\$ $(roundmult(P4_1,1e-4)) = \\\$ $(roundmult(P4_1*MD4_1/MD4_2-P4_1 ,1e-2))\$``
- To check the hedge, we calculate the value of the portfolio for different changes in yield ``\\Delta y``.
")

# ╔═╡ 37fca882-802c-4cbd-b59b-3c3084936e66
md"""
##
"""

# ╔═╡ 79976d73-a4d0-4593-860e-8cc1ee825306
begin
	deltaY4vec = [-3,-2,0,-1,1,2,3]
	portVal4 = zeros(length(deltaY4vec))
	for idx=1:length(portVal4)
		portVal4[idx] = (P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2)/(1+(r4+deltaY4vec[idx])/100)^T4_2 - F4_1/(1+(r4+deltaY4vec[idx])/100)^T4_1
	end
	df42 = DataFrame(Delta_y=deltaY4vec, PortfolioValue=portVal4)
end

# ╔═╡ bccde543-ec7e-40fc-abce-ef2300ca4e99
md"""
# Hedging Interest Rate Risk using Duration and Convexity
"""

# ╔═╡ 1bceac5b-efa5-4e95-89ee-139bdacde5cc
md"""
- In the previous example, the duration hedge worked well for small changes in interest rates.
- Can we improve the hedge for larger changes in interest rates by hedging convexity as well (i.e. heding both duration and convexity)?
- Let's consider the same setup as in the previous example.
"""

# ╔═╡ 0e2168f5-d66c-42f5-8593-60d54c589c14
begin
	T4_3 = 30
	display("")
end

# ╔═╡ 4f947c23-269d-403d-b1b5-623e90558483
md"""
##
"""

# ╔═╡ d6685025-3bca-4145-8bca-c448b8d51cb6
Markdown.parse("
- Suppose that we are a large firm and that we have issued a bond with \$ $(F4_1) par value. The bond is a zero-coupon bond with maturity in $(T4_1) years.
- Suppose that all interest rates are $(r4)%.
- Suppose that we have an additional bond to invest in to hedge convexity. This bond is a $(T4_3)-year zero coupon bond.

")

# ╔═╡ 692cbf2f-2735-4383-b76c-d1253e951f4d
md"""
##
"""

# ╔═╡ 3e5f4259-abf5-442e-8c70-672e2af8f477
Markdown.parse("
- Let's first calculate the duration, convexity, the percentage price change and the dollar price in response to a yield change ``\\Delta y`` for each of the three bonds.
- ``$(T4_1)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_1)}=\\frac{T}{1+y} = \\frac{$(T4_1)}{1+$(r4)\\%} = $(roundmult(T4_1/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_1)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_1^2+T4_1)}{(1+$(r4)\\%)^2} = $(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_1)}}{P_{$(T4_1)}}= - MD_{$(T4_1)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_1)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_1)} = P_{$(T4_1)} \\times (- MD_{$(T4_1)}) \\times \\Delta y + P_{$(T4_1)} \\times \\frac{1}{2} \\times CX_{$(T4_1)} \\times \\left( \\Delta y \\right)^2``

")

# ╔═╡ 6fc53545-aaaa-4892-933f-8a623cc857ba
md"""
##
"""

# ╔═╡ 479caa2e-d3df-42f7-accf-e271a1f0aa15
Markdown.parse("
- ``$(T4_2)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_2)}=\\frac{T}{1+y} = \\frac{$(T4_2)}{1+$(r4)\\%} = $(roundmult(T4_2/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_2)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_2^2+T4_2)}{(1+$(r4)\\%)^2} = $(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_2)}}{P_{$(T4_2)}}= - MD_{$(T4_2)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_2)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_2)} = P_{$(T4_2)} \\times (- MD_{$(T4_2)}) \\times \\Delta y + P_{$(T4_2)} \\times \\frac{1}{2} \\times CX_{$(T4_2)} \\times \\left( \\Delta y \\right)^2``


")

# ╔═╡ 0e756a4b-833a-4405-906d-6d14f2204932
md"""
##
"""

# ╔═╡ d32d5636-93e1-4429-a942-0d71c6e4a7c4
Markdown.parse("
- ``$(T4_3)``-year Zero-coupon bond (liability)
  - ``MD_{$(T4_3)}=\\frac{T}{1+y} = \\frac{$(T4_3)}{1+$(r4)\\%} = $(roundmult(T4_3/(1+r4/100),1e-4))``
  - ``\\textrm{CX}_{$(T4_3)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T4_3^2+T4_3)}{(1+$(r4)\\%)^2} = $(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T4_3)}}{P_{$(T4_3)}}= - MD_{$(T4_3)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T4_3)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T4_3)} = P_{$(T4_3)} \\times (- MD_{$(T4_3)}) \\times \\Delta y + P_{$(T4_3)} \\times \\frac{1}{2} \\times CX_{$(T4_3)} \\times \\left( \\Delta y \\right)^2``
")

# ╔═╡ ea71db37-3c90-45b4-a8e9-5143138ef7ea
md"""
##
"""

# ╔═╡ 2a0d8cc6-4b72-4586-b160-336558bbc4cb
Markdown.parse("
- Next, let's write down the balance sheet as in the previous example.
- The asset side of the balance sheet now has the $(T4_2)-year zero-coupon bond and the $(T4_3)-year zero coupon bond.
")

# ╔═╡ e1775c56-3dd7-48c3-9104-ef62a3f4fe0e
Markdown.parse("
- We assume that we enter into a position with market value `z` in the $(T4_3)-year zero coupon bond.
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 $(T4_3)-year bond: `z` | 
")

# ╔═╡ 91c49bea-9722-4a23-bf86-e31ca7adfa1f
md"""
##
"""

# ╔═╡ fd40de0d-a78d-46ae-9251-5cd869f5e7e4
Markdown.parse("
- Next, let's write down the balance sheet as in the previous example.
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\textrm{CX}_{$(T4_2)}``: `$(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))` | ``\\textrm{CX}_{$(T4_1)}``: `$(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))`
``\\Delta B_{$(T4_2)}= x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2`` | ``\\Delta B_{$(T4_1)}=$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y + $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2``
                       |
$(T4_3)-year bond: `z` |
``MD_{$(T4_3)}``: `$(roundmult(T4_3/(1+r4/100),1e-4))`|
``\\textrm{CX}_{$(T4_3)}`` `$(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))` |
``\\Delta B_{$(T4_3)}= z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2`` |
")

# ╔═╡ c91e2e36-577e-4cf1-aea6-f5090afce63c
md"""
##
"""

# ╔═╡ b8233599-8e30-4497-8b1e-deb8dbade9d6
Markdown.parse("
- Similar to the previous example, we want the total change in the value of assets and liabilities to be zero (when interest rates change by ``\\Delta y``). This means that the change in value of assets must be equal to the change in value of liabilities.

")

# ╔═╡ 9da797cb-3a79-44d1-bd05-f664bd4d8fff
Markdown.parse("
- This means, we need to have
``\$ \\Delta B_{$(T4_2)} + \\Delta B_{$(T4_3)} = \\Delta B_{$(T4_1)}\$``
``\$ x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 + z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 =$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y + $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2\$``
")

# ╔═╡ 6d3a6022-447b-4cd8-9471-966646b73304
md"""
##
"""

# ╔═╡ 0afc8de7-2000-41b0-8e32-5921449427e5
Markdown.parse("
- Since this equation must hold for all ``\\Delta y`` and for all ``(\\Delta y)^2``, we can look at all terms in ``\\Delta y`` and in ``(\\Delta y)^2`` separately.
- Terms in ``\\Delta y``: **Modified Duration Equation**
  - ``\$ x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y + z \\times (-$(roundmult(T4_3/(1+r4/100),1e-4))) \\times \\Delta y  =$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y \$``
- Terms in ``(\\Delta y)^2``: **Convexity Equation**
  - ``\$ x \\times \\frac{1}{2} ($(roundmult((T4_2^2+T4_2)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 + z \\times \\frac{1}{2} ($(roundmult((T4_3^2+T4_3)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2 = $(roundmult(P4_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T4_1^2+T4_1)/(1+r4/100)^2,1e-4))) \\times (\\Delta y)^2\$``
")

# ╔═╡ 91f43100-1e81-4e38-9dee-3cd3e2d83a23
md"""
##
"""

# ╔═╡ d89cd3ee-9c14-4c72-bc3f-cb9c9b2a5b69
Markdown.parse("
- How do we solve these two equations for `x` and `z`?
- Let's first rewrite the equations by collecting all terms in `x` and `y` on the left-hand side and the constant terms on the right-hand side and by dropping the ``\\Delta y`` and ``(\\Delta y)^2`` terms.
- ``\$ $(roundmult(MD4_2,1e-4)) \\times x  + $(roundmult(T4_3/(1+r4/100),1e-4)) \\times z =$(roundmult(MD4_1*P4_1,1e-4))\$``
``\$$(roundmult(0.5*(T4_2^2+T4_2)/(1+r4/100)^2,1e-4)) \\times x  + $(roundmult(0.5*(T4_3^2+T4_3)/(1+r4/100)^2,1e-4)) \\times z = $(roundmult(0.5*P4_1*(T4_1^2+T4_1)/(1+r4/100)^2,1e-4))\$``
")


# ╔═╡ d55cfed0-fafa-4ed9-b95f-3c55b3fb5f1d
md"""
##
"""

# ╔═╡ 99785aa6-1503-468a-8cde-23768862d42d
 Foldable("How to solve the system of equations using Excel",Markdown.parse("
 - The solution ``x`` to a system of linear equations of the form
 ``\$A x = b\$``
 - is given by
 ``\$x = A^{-1} b\$``
 - Note that in this example
\$A = \\left( {\\begin{array}{*{20}{c}}
{1.9231}&{28.8462}\\\\
{2.7737}&{429.9186}
\\end{array}} \\right)\$
\$b = \\left( {\\begin{array}{*{20}{c}}
{9495.8093}\\\\
{34352.8377}
\\end{array}} \\right)\$
  - Step 1: Open a new Excel spreadsheet and type in the equations as shown below in columns A, B, C, and D (in rows 1 and 2, respectively).
 A       | B        |  C         | D
 :-------|:---------|:-----------|:----------
 -1.9231 | -28.8462 | -6495.8093 | 6495.8093
 2.7737	 | 429.9186	| 34352.8377 | 34352.8377
  - Step 2: go into a blank cell and enter `=MMULT(MINVERSE(A2:B3),C2:C3)` and press Enter.
- Excel will show the result
\$\\left( {\\begin{array}{*{20}{c}}
{2412.698228}\\\\
{64.33947409}
\\end{array}} \\right)\$
- This means that the solution is `x= 2412.698228` and `y=64.33947409`.
"))

# ╔═╡ 25d58933-5edd-4c2e-9685-837a23810f2e
begin
 lhs4 = [MD4_2 (T4_3/(1+r4/100))
         (0.5*(T4_2^2+T4_2)/(1+r4/100)^2) (0.5*(T4_3^2+T4_3)/(1+r4/100)^2)]
 rhs4 = [(MD4_1*P4_1), (0.5*P4_1*(T4_1^2+T4_1)/(1+r4/100)^2)]
 sol4 = inv(lhs4)*rhs4
	display("")
end

# ╔═╡ dcde1dde-34ba-4fef-bc06-5ba509e3b10e
md"""
##
"""

# ╔═╡ d0903239-05fe-4a43-9256-a7b7c0bfefb7
Markdown.parse("
- The solution to this system of 2 equations in 2 unknowns is 
``\$x = $(roundmult(sol4[1],1e-4)), z = $(roundmult(sol4[2],1e-4))\$``
- Thus, we enter a position with market value of \$ $(roundmult(sol4[1],1e-4)) in the $(T4_2)-year bond, and a position with market value of \$ $(roundmult(sol4[2],1e-4)) in the $(T4_3)-year bond.
- The corresponding face values in the ``$(T4_2)``-year bond and the ``$(T4_3)``-year bonds are
\$F_{$(T4_2)} = $(roundmult(sol4[1]*(1+r4/100)^T4_2,1e-2))\$
\$F_{$(T4_3)} = $(roundmult(sol4[2]*(1+r4/100)^T4_3,1e-2))\$
")

# ╔═╡ 47f10331-5666-4a78-81fc-f4f320525d65
md"""
##
"""

# ╔═╡ 76c524dd-b323-4d3a-9357-4a87c1343066
Markdown.parse("
- The balance sheet is now
- Next, let's write down the balance sheet as in the previous example.
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `$(roundmult(sol4[1],1e-4))` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
Face value ``F_{$(T4_2)}``: $(roundmult(sol4[1]*(1+r4/100)^T4_2,1e-2)) | Face value ``F_{$(T4_1)}``: $(roundmult(F4_1,1e-2))
                        |
$(T4_3)-year bond: `$(roundmult(sol4[2],1e-4))` |
Face value ``F_{$(T4_3)}``: $(roundmult(sol4[2]*(1+r4/100)^T4_3,1e-2)) | 
")

# ╔═╡ 5e6c8dab-5ea3-4525-82f2-759b4df25fd7
md"""
##
"""

# ╔═╡ ad3747cd-fd29-4910-939f-e5082e5c86e8
Markdown.parse("
- Let's verify that the hedge works.
- The market value of our portfolio (assets minus liabilities) is ``\$ \\\$ $(roundmult(sol4[1],1e-4)) + $(roundmult(sol4[2],1e-4)) - \\\$ $(roundmult(P4_1,1e-4)) = \\\$ $(roundmult(sol4[1]+sol4[2]-P4_1 ,1e-2))\$``
- To check the hedge, we calculate the value of the portfolio for different changes in yield ``\\Delta y``.
")

# ╔═╡ 3a282e87-de92-40e5-89f7-162fc504aa7c
md"""
##
"""

# ╔═╡ f1c19865-cd68-4e9d-a9ca-5952ce2479b7
begin
	deltaY43vec = [-3,-2,0,-1,1,2,3]
	portVal43 = zeros(length(deltaY43vec))
	for idx=1:length(portVal43)
		portVal43[idx] = (sol4[1]*(1+r4/100)^T4_2)/(1+(r4+deltaY4vec[idx])/100)^T4_2 + (sol4[2]*(1+r4/100)^T4_3)/(1+(r4+deltaY4vec[idx])/100)^T4_3 - F4_1/(1+(r4+deltaY4vec[idx])/100)^T4_1
	end
	df43 = DataFrame(Delta_y=deltaY43vec, PortfolioValue=portVal43)
end

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
<input type="checkbox" value="" checked>Understand why we use Convexity and how to calculate it.<br><br>
<input type="checkbox" value="" checked>Calculate the Convexity Convexity of a portfolio.<br><br>
<input type="checkbox" value="" checked>Use Modified Duration to hedge interest rate risk.<br><br>
<input type="checkbox" value="" checked>Use Modified Duration and Convexity to hedge interest rate risk.<br><br>
</fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
# Reading
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 4
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
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
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

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

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
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

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
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

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

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

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
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

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
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─c937d82d-eafe-4940-a69f-b76a2313fb6b
# ╟─51ff9016-8ec3-406d-aed5-dc68f0cdd910
# ╟─acda8937-b591-4599-840b-34cd0267339b
# ╟─f07c5a3d-d943-458c-abfb-4a57b879f4a6
# ╟─86fe4f73-50bb-4ea1-b27f-503e65c3d4d9
# ╟─618093a8-60d3-4c2a-b128-c7cc1bd41fd3
# ╟─08c27c82-a6aa-47ce-ad6a-ead9cc896a36
# ╟─edfeb23e-0c6e-4b04-a551-2a11ab611dd3
# ╟─ba18ce52-a35d-4039-9b06-3a77c503c0d5
# ╟─52faaf0c-da7e-40f5-ab83-7ff78bf0457d
# ╟─0ef8a1c1-63c6-4ca4-99d3-6279db5887a5
# ╟─f19ee8ea-4f86-4a63-9ef8-92f22360e63a
# ╟─df657c50-9546-4e88-b135-a03dd896dfe4
# ╟─1c5d11a2-6f90-4f6a-b99a-1e4457442f8b
# ╟─29d5d4f7-904e-44e7-8a60-e5543b48008d
# ╟─7e6c008f-3ced-4cf1-a325-d66fa564a61c
# ╟─eb75afbd-07ed-4732-82d8-3da953d3459e
# ╟─14f29db1-3465-4d15-b00f-4cfb81d9d2ac
# ╟─fab999bb-f8dc-44a0-ad8d-f51bc20b646c
# ╟─17e98d7a-6d16-42c8-b127-1b8fd48e2ed3
# ╟─28d0e6f9-42fd-4122-ae6b-23aa94eb5cb0
# ╟─a04b63e4-9c71-406e-b185-a27c7083371a
# ╟─4615f144-32ed-4dbd-8fcf-7f39b7dfd61a
# ╟─1a0464c0-9112-41de-958a-bc82e44a8b81
# ╟─24213af7-4c78-4a96-baf6-db05d2087e08
# ╟─03fb80a2-8208-4124-8345-aa6c6d88a37d
# ╟─0ac1ccd8-f726-4a95-8978-5069b553e90e
# ╟─d5de39af-0dfc-4e0d-937c-85bed3cf8737
# ╟─06c2bf78-d5f2-4d8c-be00-1536b7d87546
# ╟─b8f42ad5-26e6-4336-8ea9-a5586b10a910
# ╟─ef610c94-a085-4ea9-acc8-4436d8b6e3c9
# ╟─f833d99d-dd8b-42a7-a51d-59291b8a40b2
# ╟─ed793c92-73ec-4986-923c-76bf79cec892
# ╟─8d6c5fe2-dac4-40fa-b76a-11253fb501de
# ╟─a3763cba-0366-438e-bc5d-4a5cfdf1f11e
# ╟─431ffd4b-0d7e-4c8c-bb7a-7e8b02916559
# ╟─2012d230-29ee-4ce4-a256-58b69c5ebca6
# ╟─e2b51a3d-1ea0-47cc-882f-808c82bed745
# ╟─125e2dde-ea03-4c2c-afed-d03362fd6199
# ╟─a6f5c5ec-3201-43ad-9a1f-e3133bc88e8f
# ╟─3b40838c-875f-42aa-b915-39ee0e874a77
# ╟─b1d101b3-b832-498e-a421-704bc5312985
# ╟─e00a8ff6-a0f2-45ec-af54-ef8b0541b8ea
# ╟─0306dfe7-a27d-475c-9b13-529f831efbff
# ╟─6e40255f-f102-4643-beb5-063a539369b0
# ╟─5a073f19-2d6e-46d3-a90d-fb4eaa5d8850
# ╟─5ea3d229-56ea-4ba4-b0cb-23f9dd828c96
# ╟─e4d8e509-f60e-4d0b-9418-c155296039b0
# ╟─5617fb73-7042-4896-9b60-d5aa236faa79
# ╟─9b77fac9-c667-4c48-99dd-ef2f2e726c9e
# ╟─4f604959-9951-4a21-b096-5dcdfae3688f
# ╟─976c23bb-d905-4f47-9688-aa1da4963d57
# ╟─1af4de6e-c8a3-4248-af7d-0f6a939d01a1
# ╟─016caaa6-3043-4d9d-92ca-8263eb14e9a5
# ╟─9fc68b55-c7c3-4cbc-bbd5-21a132fbd475
# ╟─e7029561-f30a-4ede-a878-245066728b89
# ╟─d1ffe738-8d2d-48ce-9e15-0d9d14c7612e
# ╟─316a9264-3b9a-43bc-956f-5a0a2cf2f35d
# ╟─a82d46b0-41c9-45a7-b3be-040ad8b8c31b
# ╟─08eec6cb-19ab-474a-8dda-6f5cc7572e17
# ╟─ffedd329-ea9b-4287-810e-c135cd168eda
# ╟─e53faa81-6620-4191-a021-f4d1f5ab5f4f
# ╟─4b485dae-2b99-4cbd-b98e-d8766f5aaba9
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─2b77f392-a2c9-4f53-8da5-b98c4f9842aa
# ╟─df1c19c4-8182-4fed-92bf-a14b9e9532ed
# ╟─87e92bc5-0dbb-4a02-b3d7-32d911bb31cd
# ╟─58e301bc-edf3-4f5e-a9e4-690dacb8b4bf
# ╟─f6114654-5263-4f87-b355-253bf2d5fb56
# ╟─c224f305-d9e9-428b-904b-96d990bbd90c
# ╟─4fa330f7-5ae5-4320-9662-323447bbf919
# ╟─ec174135-4162-4660-8a5c-082209c90dfb
# ╟─3f287e26-573f-4dbd-a79f-b71358363a63
# ╟─0275ce82-a2cf-4961-a2f6-8c2bd3db592c
# ╟─f31d870c-27b4-40d0-8327-b80bbb5581eb
# ╟─90fe35c6-0591-4331-866a-2bf0e46905ff
# ╟─e544a5b0-a1e5-47b6-8418-5c90cdf31ce0
# ╟─ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
# ╟─2c361b3b-ec06-433b-8260-f331a085b40d
# ╟─617a32eb-350f-4fdf-a576-c235b62f74c6
# ╟─9b0ce3bf-c89d-415f-b6a3-272e9beb3cbb
# ╟─c4bdb17f-b949-4966-a019-a831192dbabe
# ╟─7e32290d-2825-4205-b0dc-1a96ce80dab4
# ╟─fc228fc0-f6fb-45e1-a586-b835a22093ce
# ╟─0b15d5f0-13ad-45df-a59a-26a39a2cda51
# ╟─a06b804d-c4b6-463f-b3ba-d7f41e67ec68
# ╟─0276c4c6-e018-47b6-ae9a-ffdb5e55a7d9
# ╟─6232b5c8-6fb0-40b7-b81f-40ab24afdfb3
# ╟─1152d568-5360-401e-b264-4520c2cf09e5
# ╟─f9a70ebe-edcf-4af7-ab04-1eef2ecf236e
# ╟─eecf244a-2aa3-4d23-bc19-e22626f39f9e
# ╟─ec469f71-a70c-46bd-bcf7-edae2e17c529
# ╟─c34cab0c-7a1d-4fc6-8ac6-9c873b22c6c5
# ╟─a68fc8bb-c27a-41c9-af70-1984b473abf8
# ╟─0602f8d6-9f0d-4f21-b102-f7649bd9f905
# ╟─b23e2704-8981-4796-a191-fb864b96a00e
# ╟─c81de955-94b2-4033-a01c-99d3cd0c196c
# ╟─9da87f89-5cd0-4996-9414-bddd8c2cbb2a
# ╟─9d4b5920-0304-425a-8c06-0493925f5228
# ╟─71a8275a-dfb3-425b-8e48-9dfafe6efc01
# ╟─3b36971e-98dd-4851-a337-4f1d740d8eb6
# ╟─6ea25682-d851-4e13-bacd-1ccc5d8bdf80
# ╟─729dab93-8ac9-4da2-9ed9-09e5769dec01
# ╟─837bc716-4e33-430d-89b7-31ae7ba51c4a
# ╟─c233d6c4-794f-491a-a49a-8fd5ffdbcd30
# ╟─d77d4520-b2e5-4d9b-9016-e03405b44ef9
# ╟─7384e263-bf66-4c92-9204-2d4ed0add7a5
# ╟─47741dde-57ee-42f1-a227-480d3c9e9796
# ╟─3f0ef6f2-6b23-4799-9266-a0927e702392
# ╟─a94d61fa-4559-4bb6-86ee-efac87f3cd38
# ╟─86dcff7f-6d25-49ec-8cf3-bd8678887d47
# ╟─ec1ab99d-4cd2-4154-b872-607b7d9d46cb
# ╟─7d04d258-69a3-477a-b859-27e8a3b93c5e
# ╟─3245e9f9-c6de-43ab-90c4-e88e5a1bf28b
# ╟─b15e91a0-03bf-44e5-94ef-f294c4b205f6
# ╟─e97026b3-ec01-44ce-ab7b-21624d2310a2
# ╟─7474d772-0cb9-45e4-b6a3-7830c216c033
# ╟─f0cb66f5-9b3b-4c5c-9e1b-40e2fbcf0500
# ╟─2c4d1f76-4d9a-4841-b796-d6398dff93f0
# ╟─367e6030-3028-40a0-9a5e-cac53506f00d
# ╟─c0458366-0b9a-49ad-8b58-1f6a94655958
# ╟─25a6ae4a-9077-45da-be2b-9c98eb005074
# ╟─0c984cb2-0844-4526-8b3f-6fbf986de919
# ╟─a5331500-a5f8-404b-87a7-392faec92dd9
# ╟─f36d7ef0-0117-4b2d-8649-f09982346139
# ╟─5fcc1623-4522-455e-ac64-5681aa8895f9
# ╟─37fca882-802c-4cbd-b59b-3c3084936e66
# ╟─79976d73-a4d0-4593-860e-8cc1ee825306
# ╟─bccde543-ec7e-40fc-abce-ef2300ca4e99
# ╟─1bceac5b-efa5-4e95-89ee-139bdacde5cc
# ╟─0e2168f5-d66c-42f5-8593-60d54c589c14
# ╟─4f947c23-269d-403d-b1b5-623e90558483
# ╟─d6685025-3bca-4145-8bca-c448b8d51cb6
# ╟─692cbf2f-2735-4383-b76c-d1253e951f4d
# ╟─3e5f4259-abf5-442e-8c70-672e2af8f477
# ╟─6fc53545-aaaa-4892-933f-8a623cc857ba
# ╟─479caa2e-d3df-42f7-accf-e271a1f0aa15
# ╟─0e756a4b-833a-4405-906d-6d14f2204932
# ╟─d32d5636-93e1-4429-a942-0d71c6e4a7c4
# ╟─ea71db37-3c90-45b4-a8e9-5143138ef7ea
# ╟─2a0d8cc6-4b72-4586-b160-336558bbc4cb
# ╟─e1775c56-3dd7-48c3-9104-ef62a3f4fe0e
# ╟─91c49bea-9722-4a23-bf86-e31ca7adfa1f
# ╟─fd40de0d-a78d-46ae-9251-5cd869f5e7e4
# ╟─c91e2e36-577e-4cf1-aea6-f5090afce63c
# ╟─b8233599-8e30-4497-8b1e-deb8dbade9d6
# ╟─9da797cb-3a79-44d1-bd05-f664bd4d8fff
# ╟─6d3a6022-447b-4cd8-9471-966646b73304
# ╟─0afc8de7-2000-41b0-8e32-5921449427e5
# ╟─91f43100-1e81-4e38-9dee-3cd3e2d83a23
# ╟─d89cd3ee-9c14-4c72-bc3f-cb9c9b2a5b69
# ╟─d55cfed0-fafa-4ed9-b95f-3c55b3fb5f1d
# ╟─99785aa6-1503-468a-8cde-23768862d42d
# ╟─25d58933-5edd-4c2e-9685-837a23810f2e
# ╟─dcde1dde-34ba-4fef-bc06-5ba509e3b10e
# ╟─d0903239-05fe-4a43-9256-a7b7c0bfefb7
# ╟─47f10331-5666-4a78-81fc-f4f320525d65
# ╟─76c524dd-b323-4d3a-9357-4a87c1343066
# ╟─5e6c8dab-5ea3-4525-82f2-759b4df25fd7
# ╟─ad3747cd-fd29-4910-939f-e5082e5c86e8
# ╟─3a282e87-de92-40e5-89f7-162fc504aa7c
# ╟─f1c19865-cd68-4e9d-a9ca-5952ce2479b7
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
