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

# ╔═╡ 04d9b219-151a-4d98-9eba-9cb26390031c
#Set-up packages
begin
	
	using DataFrames, Chain, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, PrettyTables, HypertextLiteral, XLSX
	
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
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Measures of Bond Price Volatility
	</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> University of Delaware, 
	Lerner College of Business and Economics </div>
	<p style="padding-bottom:0cm"> </p>
	"""
end

# ╔═╡ 6c3f21b7-9c43-4fc4-a228-63d0ad145478
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
<input type="checkbox" value="">Understand how bond prices change with yields.<br><br>
<input type="checkbox" value="">Calculate a Macaulay Duration and understand what it is, conceptually.<br><br>
<input type="checkbox" value="">Understand what Modified Duration is and how to calculate it.<br><br>
<input type="checkbox" value="">Understand the link between Macaulay and Modified Duration.<br><br>
<input type="checkbox" value="">Use Modified Duration to
approximate bond price changes.<br><br>
</fieldset>      
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
	display("")
end

# ╔═╡ 36c63247-8ea2-4d1b-a870-0346082b31e4
begin
 function getModDuration(y,c,T,F)
	P0 = getBondPrice(y,c,T,F)
	deltaY = 0.10 
	Pplus  = getBondPrice(y+deltaY,c,T,F)
	Pminus = getBondPrice(y-deltaY,c,T,F)
	return -(Pplus-Pminus)./(2 * deltaY * P0)
 end
	display("")
end

# ╔═╡ 2def6e1d-ce4e-4f7e-89d0-511d7def60ab
md"""
# Price-Yield Relation
"""

# ╔═╡ daee0c85-2a48-4a18-bf78-9745954da7f5
md"""
- Recall that we calculate the price $P$ of a semi-annual coupon bond with coupon rate $c$, semi-annual coupon cash flows $C$, face value $F=100$, and time-to-maturity $T$ (in years) by discounting all cash flows using the bond's yield to maturity $y$.

$$P = \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 1.5}} +\ldots + \frac{100+C}{\left(1+\frac{y}{2}\right)^{2\times T}}$$

- Using the annuity formula, we can calculate the bond price $P$ as follows.

$$P= \frac{C}{y/2} \times \left( 1-\frac{1}{(1+\frac{y}{2})^{2\times T}} \right) + \frac{100}{(1+\frac{y}{2})^{2\times T}}$$


"""

# ╔═╡ 5ebd670c-46e5-494a-8fdc-f31ee8d65656
md"""
## Example
"""

# ╔═╡ 08c4d15e-7be7-4299-b7e5-378c0e963e26
md"""
##
"""

# ╔═╡ 2287fda6-a596-47fb-9e61-6f66d20ee9b7
md"""
- Last time, we looked at the bond **Price-Yield** relation. 
- Recall that we arrived at the price-yield relation by selecting values for $y$ and calculating the bond price $P(y)$ while keeping the coupon rate $c$ and time-to-maturity $T$ the same.
  - The notation $P(y)$ means the bond price if the yield-to-maturity is $y$ (keeping coupon rate $c$ and time-to-maturity $T$ fixed).
- Then, we plotted the different values of $y$ on the horizontal axis and the corresponding bond prices $P(y)$ on the vertical axis.
- In short, we plotted pairs 
$$\left(y, P(y)\right)$$ 
- where $y$ is the yield and $P(y)$ is the bond price when we use the yield $y$ to discount the bond's cash flows.
- Let's illustrate this again below.
"""

# ╔═╡ 29081514-0125-4cde-91aa-8c4d46248145
md"""
##
"""

# ╔═╡ 4a4c7d28-0e98-45c3-89bf-6a97279ede9e
md"""

"""

# ╔═╡ 4b0e84ec-bf1f-488e-a294-decda25471f0
md"""
- When we plot the *Yield* column on the horizontal axis and the *Price* column on the vertical axis, we get the price-yield relation.
- The price-yield relation shows us the bond price $P$ for specific values of the bond's yield to maturity $y$.
"""

# ╔═╡ f026a681-b92c-4472-8269-f3de5a3b6c8a
md"""
## Example
"""

# ╔═╡ f1f328d0-b278-4cba-a1fd-1ec21f466b78
@bind bttn_1 Button("Reset")

# ╔═╡ 61f2bfa4-bebc-46d3-a513-b0041883937d
begin
bttn_1
	md"""
	- Face Value $F$ [$]: $(@bind F1 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c1 Slider(0:0.125:10, default=2, show_value=true))
	- Yield $y$ [% p.a.]: $(@bind r1 Slider(0:0.125:16, default=4, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T1 Slider(0:1:30,default=3))
	"""
end

# ╔═╡ 3ad1e0aa-e468-4cda-8eaa-8e08cab9e89f
begin
	C1 = (c1/200)*F1
	CF1 =C1.*ones(convert(Int64,T1*2))
	CF1[end] = CF1[end] + F1
	CT1 = zeros(convert(Int64,T1*2))
	CT1[end] = copy(F1)
	dt1 = collect(0.5:0.5:T1)
	PV1 = CF1./(1+r1/(2*100)).^(2 .* dt1)
	PV1total = sum(PV1)
	display("")
end

# ╔═╡ 878f43da-b797-40a5-85c8-ec2c28788921
Markdown.parse("
- Let's consider a bond with ``T=$T1`` years to maturity, coupon rate ``c=$c1``% (paid semi-annually), and yield-to-maturity ``y=$r1`` %.
- The bond price is

``\$P=\\frac{$(C1[1])}{$(r1)\\%/2} \\times \\left( 1-\\frac{1}{(1+\\frac{$r1\\%}{2})^{2\\times $T1}} \\right) + \\frac{$F1}{(1+\\frac{$(r1)\\%}{2})^{2\\times $T1}} =  \$ $(roundmult(PV1total,1e-4))\$``

")

# ╔═╡ 23538759-942e-4f79-bc5b-6dbde1f0038d
begin
	yvec1 = collect(1:1.0:10)
	P1vec = zeros(length(yvec1))
	for idx=1:length(yvec1)
		P1vec[idx] = (C1/(yvec1[idx]/200)) * (1 - 1/(1+(yvec1[idx]/200))^(2*T1)) + 100/(1+yvec1[idx]/200)^(2*T1)
	end
	df1 = DataFrame(Yield=yvec1,Price=P1vec,T=T1.*ones(length(yvec1)),CouponRate=c1.*ones(length(yvec1)))
end

# ╔═╡ 990d8583-cebe-45c7-b455-009ab75c66e9
begin
	yvec12 = collect(1:0.1:10)
	P12vec = zeros(length(yvec12))
	for idx=1:length(yvec12)
		P12vec[idx] = (C1/(yvec12[idx]/200)) * (1 - 1/(1+(yvec12[idx]/200))^(2*T1)) + 100/(1+yvec12[idx]/200)^(2*T1)
	end
	
	plot(yvec12, P12vec, xlim=(yvec12[1],yvec12[end]), ylim=(0, 150),
		fontfamily="Times New Roman",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :none, title="Price-Yield Relation")
end

# ╔═╡ 32a63a37-50f0-46be-81e3-9d943648a226
md"""
##
"""

# ╔═╡ 21bd8072-e942-4bfe-8c4e-3324f2e27c98
md"""
- We see that as the yield increases, the bond price decreases.
- This is referred to as **inverse** relation between prices and yields.
  - It means that prices and yields move in opposite directions.
- We also see that the relation between prices and yields is not a straight line, but the relation has curvature. It is **convex**.
"""

# ╔═╡ 677ae628-c3cf-4dd5-bcf5-de501601f837
md"""
##
"""

# ╔═╡ bf31ea7f-f5be-4f0b-bf98-a89a028079da
md"""
- Let us now consider two bonds, *Bond A* and *Bond B*.
"""

# ╔═╡ da6adf02-d2a7-4cc3-bf21-599dde18a060
@bind bttn_2 Button("Reset")

# ╔═╡ afebfda6-bfe6-4b90-a486-51e06bf0614b
begin
bttn_2
TwoColumn(
	md"""
	**Bond A**
	- Face Value $F$ [$]: $(@bind F21 Slider(100:100:10000, default=100, show_value=true))
	- Cpn Rate $c$ [%]: $(@bind c21 Slider(0:0.125:10, default=2, show_value=true))
	- Maturity $T$ [yr]: $(@bind T21 Slider(0:1:30,default=3, show_value=true))
	""",
	md"""
	**Bond B**
	- Face Value $F$ [$]: $(@bind F22 Slider(100:100:10000, default=100, show_value=true))
	- Cpn Rate $c$ [%]: $(@bind c22 Slider(0:0.125:10, default=7, show_value=true))
	- Maturity $T$ [yr]: $(@bind T22 Slider(0:1:30,default=30, show_value=true))
	""")
end

# ╔═╡ ed3fb10e-ccbb-49bc-b1d4-224e9d9246d0
md"""
##
"""

# ╔═╡ 2c83a49f-8978-400a-a6c5-909b330461d8
md"""
- Notice that the price of Bond A and Bond B change very differently when yields change.
- Let's show this by looking at the prices of Bond A and Bond B for different values of the bond yield $y$ in a table.
"""

# ╔═╡ bc147100-a998-4698-8c68-afffe4b43a03
begin
	C21 = (c21/200)*F21
	CF21 =C21.*ones(convert(Int64,T21*2))
	CF21[end] = CF21[end] + F21

	C22 = (c22/200)*F22
	CF22 =C22.*ones(convert(Int64,T22*2))
	CF22[end] = CF22[end] + F22
	
	yvec21 = collect(1:1.0:10)
	Pvec21 = zeros(length(yvec21))
	for idx=1:length(yvec21)
		Pvec21[idx] = (C21/(yvec21[idx]/200)) * (1 - 1/(1+(yvec21[idx]/200))^(2*T21)) + 100/(1+yvec21[idx]/200)^(2*T21)
	end
	df21 = DataFrame(Yield=yvec21,Price=Pvec21,T=T21.*ones(length(yvec21)),CouponRate=c21.*ones(length(yvec21)))


	yvec22 = collect(1:1.0:10)
	Pvec22 = zeros(length(yvec22))
	for idx=1:length(yvec22)
		Pvec22[idx] = (C22/(yvec22[idx]/200)) * (1 - 1/(1+(yvec22[idx]/200))^(2*T22)) + 100/(1+yvec22[idx]/200)^(2*T22)
	end
	df22 = DataFrame(Yield=yvec22,Price=Pvec22,T=T22.*ones(length(yvec22)),CouponRate=c22.*ones(length(yvec22)))
	display("")
end

# ╔═╡ f2db6fe3-d185-4206-aa35-97f8f628deab
begin
	plot(yvec21, Pvec21, xlim=(yvec21[1],yvec21[end]), ylim=(0, 200),
		fontfamily="Times New Roman", label="Bond A",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :topright, title="Price-Yield Relation")
	plot!(yvec22, Pvec22, label="Bond B")
	idx = findlast(yvec21.==5)
	plot!([yvec21[idx];yvec21[idx]],[0;Pvec21[idx]],label="",c=:gray)
	plot!([yvec21[idx];yvec21[idx]],[0;Pvec22[idx]],label="",c=:gray)
end

# ╔═╡ e773e45a-417e-466f-9d83-170680a905b4
TwoColumn(pretty_table(HTML,df21,nosubheader=true),pretty_table(HTML,df22,nosubheader=true))

# ╔═╡ e8818bb1-2d21-42f0-9baa-a892e9dd1e45
md"""
##
"""

# ╔═╡ a7e9aaa5-d737-44c2-a820-3bf266acb673
md"""
- We will use the following notation.
-  $\Delta P$ is the dollar price change of a bond. 
   - For example, when the bond price is \$100 and it increases to \$102, then $\Delta P=2$.
-  $\frac{\Delta P}{P}$ is the percent change in the price of a bond.
   - For example, when the bond price is \$100 and it increases to \$102, then $\frac{\Delta P}{P}=2\%$
-  $\Delta y$ is the change in the yield of the bond in decimals.
   - For example, when the bond yield is 4% and it increases to 5%, then the yield change is 1% and we write $\Delta y=0.01$.
-  $P(y)$ is the bond price when the yield-to-maturity is $y$ (keeping time-to-maturity $T$ and coupon rate $c$ fixed)
"""

# ╔═╡ 96fddae6-5cee-4d61-a3e3-a26729b30a81
md"""
# Bond Duration
"""

# ╔═╡ a7a04741-53eb-4098-8a65-7adb671abe73
md"""
- **Duration** is a measure used to quantify how sensitive bond prices are to changes in interest rates.
- We will define duration as the **percent change of the bond price $\frac{\Delta P}{P}$ to a change in interest rates $\Delta y$**.
  - This **duration** is referred to as the **Modified Duration (MD)**.
  - More specifically (note the minus sign)

$$\textrm{Modified Duration} = -\frac{\Delta P / P}{\Delta y}$$
- There is a second definition of a bond's duration, the so-called **Macaulay Duration (D)**.
  - This duration measure can be interpreted as the average time-to-payment for a bond.

"""

# ╔═╡ b837d7ba-cf3d-43bf-99b1-2808966055bb
md"""
# Macaulay Duration
- The Macaulay Duration $D$ of a bond with price $P$ can be interpreted as the weighted-average time-to-payment.
- The reason becomes clear when we look at how it is calculated.
- For a semi-annual coupon bond with coupon rate $c$% (paid semi-annually), semi-annual coupon cash flows $C$, time to maturity $T$ and yield-to-maturity $y$, the Macaulay Duration ($D$) is
$$D = 0.5 \times w_{0.5} + 1.0 \times w_{1.0} + 1.5 \times w_{1.5} + \ldots + T \times w_{T} = \sum_{t=0.5}^{T} t \times w_t$$

$$w_t = \frac{\textrm{PV of time-t coupon cash flow}}{P}$$

"""

# ╔═╡ 4cbff949-54c5-42d4-8fa4-5aed54057fbc
md"""
##
"""

# ╔═╡ a969185d-1313-4696-a887-07e8a35e2145
md"""
- Note that the weights $w_t$ sum to one.
- Recall that the present value (PV) of the time-t coupon cash flow is

$$\textrm{PV of time-t coupon cash flow} =\frac{C}{(1+\frac{y}{2})^{2\times t}}$$ 
and the bond price $P$ is

$$P = \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{y}{2}\right)^{2\times 1.5}} +\ldots + \frac{100+C}{\left(1+\frac{y}{2}\right)^{2\times T}}$$
"""

# ╔═╡ c561997d-5357-489b-954d-6f86cc6815be
@bind bttn_3 Button("Reset")

# ╔═╡ 66faa79a-d2f0-476b-9c4b-a0811a7cacb9
begin
bttn_3
	md"""
	- Face Value $F$ [$]: $(@bind F3 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c3 Slider(0:0.125:10, default=8, show_value=true))
	- Yield $y$ [% p.a.]: $(@bind y3 Slider(0:0.125:16, default=6, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T3 Slider(0:1:30,default=10, show_value=true))
	"""
end

# ╔═╡ d9357c8a-17ee-4ca7-bfcf-67bac501c0d0
md"""
##
"""

# ╔═╡ d9b18e19-ef43-4988-9cf1-e365463252d4
begin
 dt3 = collect(0.5:0.5:T3)
 C3 = c3/200*F3	
 C3vec = C3.*ones(length(dt3))
 C3vec[end] = F3 + C3	
 PV3 = getBondPrice(y3,c3,T3,F3)

 D = 0
 w3 = zeros(length(dt3))
 PVC3vec= zeros(length(dt3))	
 for idx=1:length(dt3)
	global w3[idx] = (C3vec[idx]/(1+y3/200)^(2*dt3[idx]))/PV3
	global PVC3vec[idx] = (C3vec[idx]/(1+y3/200)^(2*dt3[idx]))
	global D += dt3[idx] * w3[idx]
 end
	
 str31 = L"D=%$(dt3[1]) \times \frac{\frac{C}{(1+\frac{y}{2})^{2\times %$(dt3[1])}}}{P} + "
 for idx=2:length(dt3)
	 if idx==length(dt3)
		tmpStr = L"%$(dt3[idx]) \times \frac{\frac{C}{(1+\frac{y}{2})^{2\times %$(dt3[idx])}}}{P}"
		global str31 = str31[1:end-1] * tmpStr[2:end]	 
	 else
	 tmpStr = L"%$(dt3[idx]) \times \frac{\frac{C}{(1+\frac{y}{2})^{2\times %$(dt3[idx])}}}{P} + "
	global str31 = str31[1:end-1] * tmpStr[2:end]
	 end
 end

 str32 = L"D=%$(dt3[1]) \times \frac{\frac{%$(C3)}{(1+\frac{%$(y3)\%}{2})^{2\times %$(dt3[1])}}}{%$(roundmult(PV3,1e-4))} + "
 for idx=2:length(dt3)
	 if idx==length(dt3)
		tmpStr = L"%$(dt3[idx]) \times \frac{\frac{%$(C3)}{(1+\frac{%$(y3)\%}{2})^{2\times %$(dt3[idx])}}}{%$(roundmult(PV3,1e-4))}"
		global str32 = str32[1:end-1] * tmpStr[2:end]	 
	 else
	 tmpStr = L"%$(dt3[idx]) \times \frac{\frac{%$(C3)}{(1+\frac{%$(y3)\%}{2})^{2\times %$(dt3[idx])}}}{%$(roundmult(PV3,1e-4))} + "
	global str32 = str32[1:end-1] * tmpStr[2:end]
	 end
 end
str33 = L"D = %$(roundmult(D,1e-4)) \textrm{ years}"

	df3 = DataFrame(Time=dt3, Coupon=C3vec, PVCoupon=PVC3vec,  P=PV3.*ones(length(dt3)),Wt=w3,t_times_Wt=dt3.*w3 )
		
	# display("")
end

# ╔═╡ f582a61f-e43b-442c-8d84-39b04fa1b818
Markdown.parse("
## Example
- Consider a Treasury note with time-to-maturity in ``T=$T3`` years, coupon rate ``c=$c3``%, and yield to maturity ``y=$y3``%.
  - The semi-annual coupon cash flows are ``C=\\frac{c}{2} \\times F= \\frac{$c3\\%}{2}\\times $F3 = $(roundmult(c3/200*F3,1e-4))``
  - The bond price is 

``\$P= \\frac{$C3}{$y3\\%/2} \\times \\left( 1-\\frac{1}{(1+\\frac{$y3\\%}{2})^{2\\times $T3}} \\right) + \\frac{$F3}{(1+\\frac{$y3\\%}{2})^{2\\times $T3}}=\$ $(roundmult(PV3,1e-4))
\$``

")

# ╔═╡ 3f1f0f6d-81ff-4997-bb02-c83cf15b7fe1
md"""
##
"""

# ╔═╡ 89bbbd01-5f9e-41aa-ba1f-20f25a943048
Markdown.parse("
- Using the Macaulay Duration formula, we calculate ``D`` as follows
``$str31 ``
- Plugging in the values
``$str32 ``
- Finally, the Macaulay Duration ``D`` is
``$str33``
- Note that the unit of the Macaulay Duration is __years__. Thus, the Macaulay Duration is oftentimes interpreted is a weighted-average time-to-payment.
")

# ╔═╡ 3c827a14-8ea6-402b-8735-d843b8121996
md"""
# Modified Duration
"""

# ╔═╡ 075ebf33-a7cf-41bb-9d76-f5815adcafcd
md"""
- Recall that we define duration as the **percent change of the bond price $\frac{\Delta P}{P}$ to a change in interest rates $\Delta y$**.
  - This **duration** is referred to as the **Modified Duration (MD)**
  - More specifically, let the current yield-to-maturity be $y$ and let the current bond price be $P(y)$.
  - Then, the modified duration $MD(y)$ is (note the minus sign)
$$MD = - \frac{\textrm{\% change in bond price}}{{\textrm{change in interest rates}}} = - \frac{\frac{\Delta P}{P(y)}}{\Delta y}$$

"""

# ╔═╡ a122b243-333a-406e-857d-1de7e7af4b10
md"""
##
"""

# ╔═╡ 81ef49eb-8315-49fc-a549-44bf0324fd27
md"""
- Thus, the modified duration has the following interpretation:
> If interest rates *increase* by 1 percentage point, then the *percent decrease* in the bond price is approximately equal to the modified duration.

> Thus, modified duration can be interpreted as the approximate percentage change in price for a 100-basis-point change in yield.

- **Example**: Suppose modified duration is 7. An increase in the yield from 5% to 6% is a price drop of about 7%.
"""

# ╔═╡ 51ff9016-8ec3-406d-aed5-dc68f0cdd910
md"""
## Modified Duration and the Price-Yield Relation
"""

# ╔═╡ f07c5a3d-d943-458c-abfb-4a57b879f4a6
@bind bttn_4 Button("Reset")

# ╔═╡ acda8937-b591-4599-840b-34cd0267339b
begin
bttn_4
	md"""
	- Face Value $F$ [$]: $(@bind F4 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c4 Slider(0:0.125:10, default=2, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T4 Slider(0:1:50,default=30,show_value=true))
	"""
end

# ╔═╡ 86fe4f73-50bb-4ea1-b27f-503e65c3d4d9
begin
	C4 = c4/200 * F4
	y4=6 #in percent
	yvec4 = collect(1:0.1:10)
	P4vec = zeros(length(yvec4))
	for idx=1:length(yvec4)
		P4vec[idx] = (C4/(yvec4[idx]/200)) * (1 - 1/(1+(yvec4[idx]/200))^(2*T4)) + 100/(1+yvec4[idx]/200)^(2*T4)
	end
	p4_5 = getBondPrice(5,c4,T4,F4)
	md4_5 =  getModDuration(5,c4,T4,F4)
	
	plot(yvec4, P4vec, xlim=(yvec4[1],yvec4[end]), xticks=1:1:yvec4[end], ylim=(0, 150),
		fontfamily="Times New Roman", label="Price-Yield Relation P(y)",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :topright, title="Price-Yield Relation")
	
	gradient_line = (x -> p4_5 .- 100 .* md4_5./2 .* (x .- 5))
	plot!(yvec4,gradient_line(yvec4),label="Tangent Line")
	
end

# ╔═╡ e151799d-08a6-45e2-b418-6beca872f77e
md"""
##
"""

# ╔═╡ 45a2aacc-e87e-4aee-bd31-3592c05f2671
md"""
- The tangent line approximates the price-yield relation closely near the tangency point. 
- The modified duration can be interpreted as giving us the percent price change of the bond when we assume that the price-yield relation is represented by the tangent line.
- Specifically, the modified duration $MD$ is 
$$MD \approx -\textrm{slope of the tangency line} \times \frac{1}{P}$$

"""

# ╔═╡ 714a3b0e-38fe-43d2-a143-578aecb334ad
md"""
##
"""

# ╔═╡ c4579334-c101-49af-843b-1ef06609234a
md"""
- Since we know from basic calculus what the slope of the tangency line is, we have a short-cut to calculating the modified duration.
- Specifically, recall that the slope of the tangency at the point $y$ is

$$m= \frac{P(y+\Delta y)-P(y-\Delta y)}{2\times \Delta y}$$
- This is a first-order linear approximation of the price-yield relation at today's yield $y$.
  - It means that if the yield goes up by one percentage point, the price changes by approximately this slope (times 0.01).
"""

# ╔═╡ ced1bfbf-768e-4322-915d-4e3ace4aae1e
md"""
##
"""

# ╔═╡ 08c27c82-a6aa-47ce-ad6a-ead9cc896a36
md"""
- We now use this insight about $m$ to get a formula for the modified duration $MD(y)$.
$$MD(y) \approx - \frac{P(y+\Delta y)-P(y-\Delta y)}{2\times \Delta y} \times \frac{1}{P(y)}$$
- This means that in order to calculate the modified duration given today's bond price $P(y)$ and yield $y$ we do two calculations:
  1. Increase the yield-to-maturity from $y$ to $y + \Delta y$ and calculate the bond price $P(y+\Delta y)$ (pick a small value for $\Delta y$, e.g. $\Delta y=0.001$).
  2. Decrease the yield-to-maturity from $y$ to $y - \Delta y$ and calculate the bond price $P(y-\Delta y)$ (pick a small value for $\Delta y$, e.g. $\Delta y=0.001$).
  3. Plug the values for $P(y+\Delta y)$ and $P(y-\Delta y)$ into the modified duration formula and calculate $MD(y)$.
"""

# ╔═╡ a7b5bb62-1f02-462b-b5d9-f5ba3f96452c
md"""
##
"""

# ╔═╡ 24218513-7452-49f8-8007-b281b57d8a21
md"""
##
"""

# ╔═╡ 0f51d8a4-eef7-48b3-b7dd-16fe0b357d7e
md"""
##
"""

# ╔═╡ a270eda4-1676-4dd4-90d4-ef84724aed47
begin
 y5=y3
 c5=c3
 C5=C3
 T5=T3
 F5=F3
 deltaY5 = 0.20 #percent
 p5 = getBondPrice(y5,c5,T5,F5)
 p5plus	= getBondPrice(y5+deltaY5,c5,T5,F5)
 p5minus = getBondPrice(y5-deltaY5,c5,T5,F5)
 md5 = - (p5plus-p5minus)/(2*(deltaY5/100)*p5)
 display("")
end

# ╔═╡ 8200d22c-d30c-4033-8882-1a5f4b1267f1
Markdown.parse("
- Let's compute the modified duration of a Treasury note with time-to-maturity in ``T=$T5`` years, coupon rate ``c=$c5`` %, coupon cash flow ``C=$C5`` and yield to maturity ``y=$y5`` %.
- We pick ``\\Delta y=$deltaY5``% (20 basis points).
1. We calculate ``P(y+\\Delta y)``
 ``\$P(y+\\Delta y)= \\frac{C}{(y+\\Delta y)/2} \\times \\left( 1-\\frac{1}{\\left(1+\\frac{(y+\\Delta y)}{2}\\right)^{2\\times T}} \\right) + \\frac{100}{\\left(1+\\frac{(y+\\Delta y)}{2}\\right)^{2\\times T}}\$``

``\$P(y+\\Delta y)= \\frac{$C5}{$(y3+deltaY5)\\%/2} \\times \\left( 1-\\frac{1}{\\left(1+\\frac{$(y5+deltaY5)\\%}{2}\\right)^{2\\times $T5}} \\right) + \\frac{100}{\\left(1+\\frac{$(y5+deltaY5)\\%}{2}\\right)^{2\\times $T5}}=$(roundmult(p5plus,1e-6))\$``


")

# ╔═╡ eaa76efa-1a9b-4c0b-bb57-b24646e82ad2
Markdown.parse("
2. We calculate ``P(y-\\Delta y)``
 ``\$P(y-\\Delta y)= \\frac{C}{(y-\\Delta y)/2} \\times \\left( 1-\\frac{1}{\\left(1+\\frac{(y-\\Delta y)}{2}\\right)^{2\\times T}} \\right) + \\frac{100}{\\left(1+\\frac{(y-\\Delta y)}{2}\\right)^{2\\times T}}\$``

``\$P(y+\\Delta y)= \\frac{$C5}{$(y5-deltaY5)\\%/2} \\times \\left( 1-\\frac{1}{\\left(1+\\frac{$(y5-deltaY5)\\%}{2}\\right)^{2\\times $T5}} \\right) + \\frac{100}{\\left(1+\\frac{$(y5-deltaY5)\\%}{2}\\right)^{2\\times $T5}} =$(roundmult(p5minus,1e-6))\$``
")

# ╔═╡ c13779ca-df51-46b6-b8d0-35266bcf1b42
Markdown.parse("
3. We calculate the modified duration ``MD(y)``
``\$MD(y) = - \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{2\\times \\Delta y} \\times \\frac{1}{P(y)}\$``

``\$MD($y5\\%) = - \\frac{$(roundmult(p5plus,1e-4))-$(roundmult(p5minus,1e-4))}{2\\times $(deltaY5/100)} \\times \\frac{1}{$(roundmult(p5,1e-4))}=$(roundmult(md5,1e-6))\$``

- This means that when interest rates increase by 1 percentage point, the price of the bond declines by $(roundmult(md5,1e-2)) percent.
")

# ╔═╡ a1e06127-098d-470a-a5d2-b3d54165d820
md"""
## Relation between Macaulay Duration and Modified Duration
"""

# ╔═╡ f13f89cf-c3ed-47b1-8e99-f14d0432f68d
md"""
- For a semi-annual coupon bond with yield $y$ (semi-annually compounded), the Macaulay Duration $D$ and Modified Duration $MD$ are related as follows:

$$MD(y) = \frac{D}{1+\frac{y}{2}}$$

- For a zero-coupon bond, the Macaulay Duration is equal to the maturity of the bond.
- Thus, for a zero coupon bond with maturity in $T$ years (and semi-annual yield $y$), we have

$$MD(y) = \frac{T}{1+\frac{y}{2}}$$

"""

# ╔═╡ 33872352-c2f4-4f1c-a0e6-d4fbc22b3038
md"""
# Using Duration to estimate Bond Price Changes
"""

# ╔═╡ c94c665f-88ed-4be8-8a77-1644ca0eb828
md"""
- To estimate percent-changes in the price of a bond $\left(\Delta P/P\right)$ when the yield changes by $\Delta y$, we use

$$\frac{\Delta P}{P} = -MD(y) \times \Delta y$$

- Intuitively, this means

$$\textrm{\% Change in Bond Price} = - \textrm{Modified Duration} \times \textrm{Change in Yield}$$
"""

# ╔═╡ 554ed557-ac54-4599-be94-ff42706adec3
md"""
##
"""

# ╔═╡ 7b608577-71fd-4518-ae94-ca8587f0a82b
md"""
- However, this equation is an approximation, and it gives a result that is different from the *actual* price change as yield changes become larger.
  - We see this in the price-yield relation. The tangent line approximates the price-yield relation close to the tangent point at the current yield y, but gets more and more inaccurate as we move away from the tangent point. The reason why the approximation gets worse is because the price-yield relation is convex.
"""

# ╔═╡ 03da8abc-4973-4781-8b1f-372f75bb0d03
md"""
##
"""

# ╔═╡ 49656330-8647-40de-b43c-26fed8edbae9
Markdown.parse("
- To illustrate this, let's consider a Treasury note with time-to-maturity ``T=$T5`` years, coupon rate ``c=$c5`` %, coupon cash flows of ``C=$C5``, face value ``F=$F5``, and yield to maturity ``y=$y5``%.
- The bond's modified duration is ``MD($y5\\%)=$(roundmult(md5,1e-6))``
- Suppose interest rates increase and the bond's  yield changes by 0.5% (``\\Delta y =0.0050``).
- We calculate the percentage change in the bond price as

``\$\\frac{\\Delta P}{P} = -MD(y) \\times \\Delta y = - $(roundmult(md5,1e-6)) \\times 0.005 = $(roundmult(-md5*0.005,1e-6)) = $(roundmult(-md5*0.005*100,1e-2)) \\%\$``

- Thus, we estimate that the bond price declines by ``$(roundmult(-md5*0.005*100,1e-2)) \\%`` when the bond's yield increases by 0.5% (50 basis points).
")

# ╔═╡ 1e0baca0-d910-4dcf-97f4-4a1107a330b4
md"""
##
"""

# ╔═╡ 2e9c9bb6-719a-4703-9a40-d0a5a6f46066
Markdown.parse("
- What is the *actual* percent-change in the bond price?
``\$\\frac{\\Delta P}{P} = \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{P}=\\frac{P($(y5)\\%+0.5\\%)-P(y=$(y5)\\%-0.5\\%)}{P}\$``

``\$\\frac{\\Delta P}{P} =\\frac{$(roundmult(getBondPrice(y5+0.5,c5,T5,F5),1e-4))-$(roundmult(p5,1e-4))}{$(roundmult(p5,1e-4))}=$(roundmult(  (getBondPrice(y5+0.5,c5,T5,F5)-p5)/p5,1e-6))=$(roundmult(100*  (getBondPrice(y5+0.5,c5,T5,F5)-p5)/p5,1e-2))\\%\$``
- We see that the actual percent price change is ``$(roundmult(100*  (getBondPrice(y5+0.5,c5,T5,F5)-p5)/p5,1e-2))\\%`` and the approximated percent price change is ``$(roundmult(-md5*0.005*100,1e-2)) \\%``.
- Thus, there is an approximation error. 
- How large this error is depends on how large the yield change ``\\Delta y`` is.
- Let's illustrate this in a table.
")

# ╔═╡ aff83ff4-6f97-4865-a77c-522fd78d87c0
md"""
##
"""

# ╔═╡ eafd1404-d88b-4b23-8385-c8540dd17552
begin

	y6=y5
	c6=c5
	C6=C5
	T6=T5
	F6=F5
	p6 = getBondPrice(y6,c6,T6,F6)
	deltaY6=deltaY5 	 
	y6vec = collect(0.5:0.5:15)
	delta6vec = zeros(length(y6vec))
	MD6vec = zeros(length(y6vec))
	P6new = zeros(length(y6vec))
	P6MD = zeros(length(y6vec))
	deltaP6vecActual = zeros(length(y6vec))
	deltaP6vecMD = zeros(length(y6vec))
	for idx=1:length(MD6vec)
		delta6vec[idx] = y6vec[idx] .- y6
	 	p6plus	= getBondPrice(y6+deltaY6,c6,T6,F6)
	 	p6minus = getBondPrice(y6-deltaY6,c6,T6,F6)
	 	MD6vec[idx] = - (p5plus-p5minus)/(2*(deltaY6/100)*p5)
		P6new[idx] = getBondPrice(y6+delta6vec[idx],c6,T6,F6)
		deltaP6vecActual[idx] = P6new[idx]-p6
		deltaP6vecMD[idx] = p6 .* (-MD6vec[idx]*delta6vec[idx]./100)
		P6MD[idx] = p6 + deltaP6vecMD[idx]
	end
	df6 = DataFrame(CurrentYield=y6.*ones(length(y6vec)),NewYield=y6vec, YieldChange=delta6vec,ActualPrice=P6new,MDPrice=P6MD,MD_PriceChange=deltaP6vecMD,ActualPriceChange=deltaP6vecActual)
end

# ╔═╡ 06430c95-795e-4334-8a83-2034136349b7
md"""
##
"""

# ╔═╡ 8e1f9c3d-8dc6-432b-8794-da8691a77c28
md"""
- The take-away is that using Modified Duration to calculate price changes of a bond works well when yield changes are small.
- The approximation error becomes severe when yield changes become large.
- As shown below, this is because the actual price-yield relation is convex (not linear as on the straight line).
- We can improve the approximation by taking the curvature of the price-yield relation into account. 
- To achieve this, we will add a **convexity** term to the price change formula.
- Specifically,
$$\frac{\Delta P}{P} = -MD(y) \times \Delta y$$
- becomes
$$\frac{\Delta P}{P} = -MD(y) \times \Delta y + \frac{1}{2} \textrm{ Convexity } (\Delta y)^2$$ 
"""

# ╔═╡ 8b8065a9-0b1b-4618-9051-5cfea7eed01b
md"""
##
"""

# ╔═╡ 4202d79d-6c18-4114-8f38-d0a4a700508c
begin
	plot(yvec4, P4vec, xlim=(yvec4[1],yvec4[end]), xticks=1:1:yvec4[end], ylim=(0, 150),
		fontfamily="Times New Roman", label="Price-Yield Relation P(y)",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :topright, title="Price-Yield Relation")
	
	plot!(yvec4,gradient_line(yvec4),label="Tangent Line")
end

# ╔═╡ 9a3d1747-dd2f-4634-8552-618b7cdefc88
md"""
##
"""

# ╔═╡ 59985e84-56f4-420c-90e7-f20d9dd41fdf
md"""
> Practice Problem
> - A portfolio manager is considering the purchase of a bond with a 5.5% coupon rate that pays interest annually and matures in three years. If the required rate of return on the bond is 5%, the price of the bond per 100 of par value is closest to: 
>   - (A) 98.65 
>   - (B) 101.36 
>   - (C) 106.43 
"""

# ╔═╡ c59d7b00-8d49-42c5-bd75-dedaf9d43a3e
md"""
!!! hint
    - We know that since the coupon rate is higher than the yield, the bond is trading at a premium and should have a price greater than $100.0. 
    - Thus, (A) cannot be the answer.
    - Next, we know that if the yield was 5.5% instead of 5%, the price of the     bond would be $100 as it would be trading at par.
    - We also know that the modified duration of the bond is < 3.0. 
    - This means that a decline of yield from 5.5% to 5% has at most an effect on the    price of 3% $\times$ 0.5 = 1.5%.
    - Since $(1 + 0.015) \times 100 = 101.5$, the price of (C) is too high and it     cannot be the answer.
    - This leaves (B) as the correct answer.
"""

# ╔═╡ c7609399-28b0-4138-a248-6bf6e4185655
md"""
##
"""

# ╔═╡ eab2d2e3-9fbe-4cc7-9a04-b1dd74cbc208
md"""
> Practice Problem
>
>Which bond will most likely experience the smallest percent change in price if the market discount rates for all three bonds increase by 100 bps?
>
> Bond    |    Price    |    Coupon Rate    | Time-to-Maturity $T$
> :-------|:------------|:------------------|:-----------------------
> A       | 101.886     | 5%                | 2 years   
> B       | 100.000     | 6%                | 2 years   
> C       | 97.327      | 5%                | 3 years   
"""

# ╔═╡ 179c4b66-b7b8-408e-9f6e-d3a257f30f6b
md"""
!!! hint
    - Bond C, which has the longest maturity, is likely to have the largest modified  duration, so is not the answer.
    - Bonds A and B have the same maturity, but B has higher coupons, so more front-    loaded payments.
    - Thus, B is likely to have a lower modified duration than A and the answer is (    B).
"""

# ╔═╡ 59260217-2db5-473a-8801-4446343dabb4
md"""
# Duration with Term Structure of Interest Rates
"""

# ╔═╡ c499aa0c-e37a-4012-bd21-d4a25e192be6
md"""
- Thus far, we have assumed that the interest rate that changes is the yield of the bond $y$. Implicit in this assumption is that we assumed that the term structure of interest rates is flat and all interest rates change by the same small amount $\Delta y$.
- Next, we consider how we compute modified duration, when we are given a term structure of interest rates.
"""

# ╔═╡ 7aa8a914-928a-4bc7-8a04-8509f80d718f
md"""
##
"""

# ╔═╡ 8089e64c-705c-4f04-9ea1-fe9dfdacd980
Markdown.parse("
- When we are given a term structure of interest rates, we can still use the modified duration formula 

``\$MD = - \\frac{P^{+}-P^{-}}{2\\times \\Delta r} \\times \\frac{1}{P}\$``

- and calculate percent price changes using

``\$ \\frac{\\Delta P}{P} = -MD \\times \\Delta r\$``


")

# ╔═╡ 714a4fc6-a76a-4d69-823d-057791dda148
md"""
##
"""

# ╔═╡ 4a51f1ac-06f0-42af-ba8f-ac7d1d732966
Markdown.parse("
- In the formula for ``MD``, 
  - the term ``P^{+}`` is the price of the bond when the entire term structure is shifted upward by the same amound ``\\Delta r`` (e.g. ``\\Delta r = 0.001``).
  - the term ``P^{-}`` is the price of the bond when the entire term structure is shifted down by the same amound ``\\Delta r``.
  - As before, ``P`` is the current bond price.
")

# ╔═╡ 05d19cdb-f859-4da8-861f-01d9a8a936f7
md"""
##
"""

# ╔═╡ c67d4817-b345-440c-93b4-584ddf0eec0e
md"""
- To illustrate this, suppose we want to calculate the modified duration $MD$ of a bond when the term structure of interest rates is upward sloping. 
- Specifically, suppose we are given a 5-year bond with face value $F=100$, coupon rate $c=4$%, and annual coupon cash flows $C=4%$.
"""

# ╔═╡ 21a1456f-8ef1-4e0e-8680-41f923f364d5
md"""
##
"""

# ╔═╡ 1975c1f0-0885-4fea-8c1e-8a8b36fc28ac
md"""
##
"""

# ╔═╡ dc5248ba-4e93-495d-ad62-a3051d53aad0
md"""
##
"""

# ╔═╡ c02abf1c-b782-4ce8-8847-4f98e2d0fff3
md"""
##
"""

# ╔═╡ 0049e282-c3d7-478d-ba18-b79108490ec8
md"""
##
"""

# ╔═╡ 8e700fde-e2f9-449f-bd74-564af939d387
begin
 r7vec = [2,3,5,6,8]
 dt7vec = [1,2,3,4,5]
 F7 = 100
 c7 = 4
 C7 = c7/100*F7	
 C7vec = C7 .* ones(length(dt7vec))	
 C7vec[end] = F7 + C7
 p7 = sum(C7vec ./ (1 .+ r7vec./100).^(dt7vec))
	
 r7vecplus = [2,3,5,6,8] .+ 0.1
 p7plus = sum(C7vec ./ (1 .+ r7vecplus./100).^(dt7vec))
 r7vecminus = [2,3,5,6,8] .- 0.1	
 p7minus = sum(C7vec ./ (1 .+ r7vecminus./100).^(dt7vec))
 MD7 = -(p7plus-p7minus)/(2*0.1/100*p7)	
 display("")

 r7vecplusplus = [2,3,5,6,8] .+ 0.2
 p7plusplus = sum(C7vec ./ (1 .+ r7vecplusplus./100).^(dt7vec))	
 display("")
end

# ╔═╡ 6c502b38-5061-485a-a219-2fe7488d0f71
md"""
- Assume the following zero-coupon yield curve with **annual** compounding.

t     |    1 year   |    2 year    |    3 year    |    4 year    |   5 year   
:-----|:--------|:--------|:--------|:--------|:------
$r_t$     | $r_1$=$(r7vec[1])% |$r_2$=$(r7vec[2])% |$r_3$=$(r7vec[3])% |$r_4$=$(r7vec[4])% |$r_5$=$(r7vec[5])%
- Recall that under **annual** compounding, the price of a $T$-year bond is caluclated as

$$P = \frac{C}{(1+r_1)^1} + \frac{C}{(1+r_2)^2} + \ldots + \frac{C+F}{(1+r_T)^T}$$
"""

# ╔═╡ 3882b14f-7ba0-4b48-b3fa-1ed7f0aa2808
Markdown.parse("
- To calculate the modified duration ``MD``, let's first calculate the current bond price.

``\$P = \\frac{C}{(1+r_1)^1} + \\frac{C}{(1+r_2)^2} + \\frac{C}{(1+r_3)^3} + \\frac{C}{(1+r_4)^4} + \\frac{F+C}{(1+r_5)^5}\$``

``\$P = \\frac{$(C7vec[1])}{(1+$(r7vec[1])\\%)^{$(dt7vec[1])}} + \\frac{$(C7vec[2])}{(1+$(r7vec[2])\\%)^{$(dt7vec[2])}} + \\frac{$(C7vec[3])}{(1+$(r7vec[3])\\%)^{$(dt7vec[3])}}+ \\frac{$(C7vec[4])}{(1+$(r7vec[4])\\%)^{$(dt7vec[4])}}+ \\frac{$(C7vec[5])}{(1+$(r7vec[5])\\%)^{$(dt7vec[5])}} = $(roundmult(p7,1e-6))\$``

")


# ╔═╡ 4c8c68ab-195c-488f-8b9f-aa97f7378dc1
Markdown.parse("
- Next, we shift the term structure of interest rates up and down by ``\\Delta r=0.1 \\%``.
- Shifting the term structure up by ``+\\Delta r`` gives us
 t     |    1 year   |    2 year    |    3 year    |    4 year    |   5 year   
:-----|:--------|:--------|:--------|:--------|:------
``r_t``     | ``r_1=$(r7vecplus[1])`` | ``r_2=$(r7vecplus[2])`` | ``r_3=$(r7vecplus[3])`` |``r_4=$(r7vecplus[4])``% |``r_5=$(r7vecplus[5])``

``\$P^+ = \\frac{$(C7vec[1])}{(1+$(r7vecplus[1])\\%)^{$(dt7vec[1])}} + \\frac{$(C7vec[2])}{(1+$(r7vecplus[2])\\%)^{$(dt7vec[2])}} + \\frac{$(C7vec[3])}{(1+$(r7vecplus[3])\\%)^{$(dt7vec[3])}}+ \\frac{$(C7vec[4])}{(1+$(r7vecplus[4])\\%)^{$(dt7vec[4])}}+ \\frac{$(C7vec[5])}{(1+$(r7vecplus[5])\\%)^{$(dt7vec[5])}} = $(roundmult(p7plus,1e-6))\$``
")

# ╔═╡ d2825fe6-901a-48ba-a7d0-96cf91928bff
Markdown.parse("
- Shifting the term structure down by ``-\\Delta r=-0.1\\%`` gives us
t     |    1 year   |    2 year    |    3 year    |    4 year    |   5 year   
:-----|:--------|:--------|:--------|:--------|:------
``r_t``     | ``r_1=$(r7vecminus[1])`` | ``r_2=$(r7vecminus[2])`` | ``r_3=$(r7vecminus[3])`` |``r_4=$(r7vecminus[4])``% |``r_5=$(r7vecminus[5])``


``\$P^- = \\frac{$(C7vec[1])}{(1+$(r7vecminus[1])\\%)^{$(dt7vec[1])}} + \\frac{$(C7vec[2])}{(1+$(r7vecminus[2])\\%)^{$(dt7vec[2])}} + \\frac{$(C7vec[3])}{(1+$(r7vecminus[3])\\%)^{$(dt7vec[3])}}+ \\frac{$(C7vec[4])}{(1+$(r7vecminus[4])\\%)^{$(dt7vec[4])}}+ \\frac{$(C7vec[5])}{(1+$(r7vecminus[5])\\%)^{$(dt7vec[5])}} = $(roundmult(p7minus,1e-6))\$``

")

# ╔═╡ b810ed45-7680-4ab1-83f6-9206fa267bdf
Markdown.parse("
- Thus, the modified duration ``MD`` is


``\$MD = - \\frac{P^{+}-P^{-}}{2\\times \\Delta r} \\times \\frac{1}{P}\$``

``\$MD = - \\frac{$(roundmult(p7plus,1e-6))-$(roundmult(p7minus,1e-6))}{2\\times 0.01\\%} \\times \\frac{1}{$(roundmult(p7,1e-6))} = $(roundmult(MD7,1e-6))\$``
")

# ╔═╡ 4b1f1c1a-8943-4edb-9f56-ed95086e4861
Markdown.parse("
- We can now compute bond price changes when the term structure of interest rates shifts in parallel, i.e. all zero-coupon yields ``r_t`` increase or decrease by the same amount ``\\Delta r``.
- To illustrate this, suppose the term structure of interest rates shifts up by 0.2%.
- Then, the approximate dollar price change of the bond is 

``\$ \\Delta P = -MD \\times \\Delta r \\times P = - $(roundmult(MD7,1e-6)) \\times 0.2\\% \\times $(roundmult(p7,1e-4)) = $(roundmult(-MD7*0.2/100*p7,1e-6))\$``

  - For comparison, the actual price change is $(roundmult(p7plusplus-p7,1e-6)).
")

# ╔═╡ cdfa5440-90e9-41e5-ac45-6db6081bde48
md"""
# Duration of Bond Portfolios
"""

# ╔═╡ d9c88050-3a34-4c26-96cf-d9e5f0bf9b66
md"""
- Thus far, we have considered the case of a single bond and have calculated the modified duration.
- When we have a portfolio of bonds, we calculate the modified duration of the bond portfolio using the modified durations of the individual bonds in the portfolio.
- Specifically, suppose the bond portfolio consists of $B$ bonds. We denote the individual bonds by $b=1,...,B$.
- The portfolio is assumed to consist of $N_b$ units of each bond $b$.
- Each bond is assumed to have a price of $P_b$ per $100 par value. 

"""

# ╔═╡ d7d3eae4-b1fa-418f-a907-0c819410a694
md"""
##
"""

# ╔═╡ a83e02b9-776e-426e-98c1-03d95781a357
md"""
- We write the fraction of the position in bond $b$ to the total portfolio value $P_{\textrm{Portfolio}}$ as
$$w_b = \frac{n_b\times P_b}{P_{\textrm{Portfolio}}}$$
- Note that the total value of the bond portfolio is
$$P_{\textrm{Portfolio}} = n_1 \times P_1 + \ldots + n_B \times P_B$$
- Then, we calculate the modified duration $MD_{\textrm{Portfolio}}$ of the bond portfolio as the weighted average of the modified durations of the individual bonds.
  
$$MD_{\textrm{Portfolio}} = w_1 \times MD_1 + w_2 \times MD_2 + \ldots + w_B \times MD_B$$

"""

# ╔═╡ 4506af8a-6a64-4e96-aa81-021979a3ded2
md"""
## Example
- Suppose that you own a portfolio of zero-coupon bonds. All yields are annually compounded. 
- Calculate the modified duration of the portfolio.

Bond   |  Maturity     | Yield     | Face value 
:------|:--------------|:----------|:-------------
H      | 1             |  2%       | 40
I      | 2             | 3%        | 40
J      | 3             | 5%        | 40
K      | 4             | 6%        | 40
L      | 5             | 8%        | 1040

"""

# ╔═╡ 14cc3a2e-7e23-4bd3-8476-208d2f19a500
begin
	matVec8 = [1,2,3,4,5]
	yVec8 = [2,3,5,6,8]
	fVec8 = [40,40,40,40,1040]
	pVec8 = 100 ./ (1 .+ yVec8/100).^matVec8
	nB8 = fVec8./100
	MD8 = matVec8 ./ (1 .+ (yVec8./100) )
	Pb8 = sum((nB8 .* pVec8))
	wB8 = (nB8 .* pVec8) ./ Pb8
	df8 = DataFrame(Bond=["H","I","J","K","L"],Maturity=matVec8,Yield=yVec8,FaceValue=fVec8,PricePer100=pVec8,nB=nB8, MD=MD8, Pb =Pb8, wb=wB8, wB_MD=wB8.*MD8)
	display("")
end

# ╔═╡ 25e0b6ce-9863-476c-8b49-04042e8037bc
md"""
##
"""

# ╔═╡ 65f772c0-2daf-4676-9397-8787ba22dfb4
md"""
- Let's first calculate the the prices of the zero coupon bonds per \$100 face value.
- Recall, that the price of a $T$-year maturity zero-coupon bond with yield $y_T$ (annually compounded) is given by

$$P_T = \frac{100}{(1+y_T)^T}$$

"""

# ╔═╡ 700876a3-6e1d-4a45-86d5-f1edcef2d8e5
md"""
##
"""

# ╔═╡ cff6bfa5-b56d-4210-98fe-d0e08e380189
df8[:,1:5]

# ╔═╡ 19216db0-e54a-4f94-b452-28d56f670eb9
md"""
- Next, let's calculate the number of units $n_b$ for each bond $b$ in the portfolio.
- The number of bonds is simply the actual face value divided by 100 face value (which we used to calculate the bond price).
  - For instance for bond H, it is \$40/\$100=0.4
"""

# ╔═╡ a9a1fa37-000c-46e1-b529-ce8aa964a48e
md"""
##
"""

# ╔═╡ 92399c76-2da5-404e-b3fd-e136a95a5590
df8[:,1:6]

# ╔═╡ c25aaf38-8878-4fc3-95a5-3673a7bc9851
md"""
##
"""

# ╔═╡ 7db62ef0-0d0e-4255-b7ff-66edd382ddd9
md"""
- Next, we calculate the modified durations of the zero-coupon bonds.
- Recall that the modified duration $MD$ of a zero-coupon bond with $T$-years to maturity and yield $y_T$ (annually compounded) is

$$MD=\frac{T}{1+y}$$

- For instance, for bond L it is $MD_5=5/(1+8\%)=4.6296$
"""

# ╔═╡ fc111ca8-46b7-46be-94e1-e26e80cf626e
md"""
##
"""

# ╔═╡ 2e343571-a587-4ae5-a855-230e9ea3d67d
df8[:,1:7]

# ╔═╡ 2f9dab49-3257-4ff6-aa0c-c2185cffaa89
md"""
##
"""

# ╔═╡ 34d28786-b3ed-41ef-b50b-6554ba01cecd
md"""
- Next, we calculate the total value of the bond portfolio.
- The value of the bond portfolio $P_b$ is the sum of the values of the positions in the individual bonds. The position in bond $b$ is worth the number of units times the bond price, i.e. $n_b \times P_b$.
"""

# ╔═╡ 0cc86cd8-b6eb-4165-830a-2c47560dcb81
md"""
##
"""

# ╔═╡ 7d39dd1b-af1b-471c-adb4-22195179cadc
df8[:,1:8]

# ╔═╡ a0206df4-dbde-4ee8-b3f2-a655080c0c93
md"""
##
"""

# ╔═╡ fdb6864f-68d0-43c6-86fe-d507d2169d3a
md"""
- Now we can calculate the portfolio weights

$$w_b = \frac{n_b\times P_b}{P_{\textrm{Portfolio}}}$$
"""

# ╔═╡ e3c09b6e-995c-4ca6-9953-af08249f2c95
md"""
##
"""

# ╔═╡ 87f2e8e4-f10e-4e7b-81f3-ba303c7fa17b
df8[:,1:9]

# ╔═╡ 4a4880a5-3087-428e-850e-d9cbf71c01e8
md"""
##
"""

# ╔═╡ 0d35a79d-b525-4f8a-9afd-02c4bcec2ffc
md"""
- As the last step, we compute the modified duration of the portfolio $MD_{\textrm{Portfolio}}$

$$MD_{\textrm{Portfolio}} = w_1 \times MD_1 + w_2 \times MD_2 + \ldots + w_B \times MD_B$$
"""

# ╔═╡ 2b3e2eb5-304a-4d4b-a658-0b5d4d8c1995
md"""
##
"""

# ╔═╡ db7731fc-a4d1-41bb-b478-8ee8ff0fc9a0
df8[:,1:10]

# ╔═╡ ec46999c-1974-4164-a8ec-82a6cbadba31
md"""
##
"""

# ╔═╡ f3b75bd7-98c9-44a6-bf83-0e7825ed53df
Markdown.parse("
``\$MD_{\\textrm{Portfolio}} = $(roundmult(df8.wB_MD[1],1e-4)) + $(roundmult(df8.wB_MD[2],1e-4)) + $(roundmult(df8.wB_MD[3],1e-4)) + $(roundmult(df8.wB_MD[4],1e-4)) + $(roundmult(df8.wB_MD[5],1e-4))\$``

``\$MD_{\\textrm{Portfolio}} = $(roundmult(sum(df8.wB_MD),1e-6))\$``
")


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
<input type="checkbox" value="" checked>Understand how bond prices change with yields.<br><br>
<input type="checkbox" value="" checked>Calculate a Macaulay Duration and understand what it is, conceptually.<br><br>
<input type="checkbox" value="" checked>Understand what Modified Duration is and how to calculate it.<br><br>
<input type="checkbox" value="" checked>Understand the link between Macaulay and Modified Duration.<br><br>
<input type="checkbox" value="" checked>Use Modified Duration to
approximate bond price changes.<br><br>
<input type="checkbox" value="" checked>Know how to calculate the Modified Duration of a bond portfolio.<br><br>
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
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
Chain = "~0.4.10"
DataFrames = "~1.3.1"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.25.3"
PlutoUI = "~0.7.27"
PrettyTables = "~1.3.1"
XLSX = "~0.7.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.6.5"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "49f14b6c56a2da47608fe30aed711b5882264d7a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.11"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Chain]]
git-tree-sha1 = "339237319ef4712e6e5df7758d0bccddf5c237d9"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.10"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "cfdfef912b7f93e4b848e80b9befdf9e331bc05a"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7eda8e2a61e35b7f553172ef3d9eaa5e4e76d92e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "244586bc07462d22aed0113af9c731f2a518c93e"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.10"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[deps.XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "96d05d01d6657583a22410e3ba416c75c72d6e1d"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.8"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─41d7b190-2a14-11ec-2469-7977eac40f12
# ╟─04d9b219-151a-4d98-9eba-9cb26390031c
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─6c3f21b7-9c43-4fc4-a228-63d0ad145478
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─36c63247-8ea2-4d1b-a870-0346082b31e4
# ╟─3ad1e0aa-e468-4cda-8eaa-8e08cab9e89f
# ╟─2def6e1d-ce4e-4f7e-89d0-511d7def60ab
# ╟─daee0c85-2a48-4a18-bf78-9745954da7f5
# ╟─5ebd670c-46e5-494a-8fdc-f31ee8d65656
# ╟─878f43da-b797-40a5-85c8-ec2c28788921
# ╟─08c4d15e-7be7-4299-b7e5-378c0e963e26
# ╟─2287fda6-a596-47fb-9e61-6f66d20ee9b7
# ╟─29081514-0125-4cde-91aa-8c4d46248145
# ╟─23538759-942e-4f79-bc5b-6dbde1f0038d
# ╟─4a4c7d28-0e98-45c3-89bf-6a97279ede9e
# ╟─4b0e84ec-bf1f-488e-a294-decda25471f0
# ╟─f026a681-b92c-4472-8269-f3de5a3b6c8a
# ╟─61f2bfa4-bebc-46d3-a513-b0041883937d
# ╟─f1f328d0-b278-4cba-a1fd-1ec21f466b78
# ╟─990d8583-cebe-45c7-b455-009ab75c66e9
# ╟─32a63a37-50f0-46be-81e3-9d943648a226
# ╟─21bd8072-e942-4bfe-8c4e-3324f2e27c98
# ╟─677ae628-c3cf-4dd5-bcf5-de501601f837
# ╟─bf31ea7f-f5be-4f0b-bf98-a89a028079da
# ╟─afebfda6-bfe6-4b90-a486-51e06bf0614b
# ╟─da6adf02-d2a7-4cc3-bf21-599dde18a060
# ╟─f2db6fe3-d185-4206-aa35-97f8f628deab
# ╟─ed3fb10e-ccbb-49bc-b1d4-224e9d9246d0
# ╟─2c83a49f-8978-400a-a6c5-909b330461d8
# ╟─bc147100-a998-4698-8c68-afffe4b43a03
# ╟─e773e45a-417e-466f-9d83-170680a905b4
# ╟─e8818bb1-2d21-42f0-9baa-a892e9dd1e45
# ╟─a7e9aaa5-d737-44c2-a820-3bf266acb673
# ╟─96fddae6-5cee-4d61-a3e3-a26729b30a81
# ╟─a7a04741-53eb-4098-8a65-7adb671abe73
# ╟─b837d7ba-cf3d-43bf-99b1-2808966055bb
# ╟─4cbff949-54c5-42d4-8fa4-5aed54057fbc
# ╟─a969185d-1313-4696-a887-07e8a35e2145
# ╟─f582a61f-e43b-442c-8d84-39b04fa1b818
# ╟─66faa79a-d2f0-476b-9c4b-a0811a7cacb9
# ╟─c561997d-5357-489b-954d-6f86cc6815be
# ╟─d9357c8a-17ee-4ca7-bfcf-67bac501c0d0
# ╟─d9b18e19-ef43-4988-9cf1-e365463252d4
# ╟─3f1f0f6d-81ff-4997-bb02-c83cf15b7fe1
# ╟─89bbbd01-5f9e-41aa-ba1f-20f25a943048
# ╟─3c827a14-8ea6-402b-8735-d843b8121996
# ╟─075ebf33-a7cf-41bb-9d76-f5815adcafcd
# ╟─a122b243-333a-406e-857d-1de7e7af4b10
# ╟─81ef49eb-8315-49fc-a549-44bf0324fd27
# ╟─51ff9016-8ec3-406d-aed5-dc68f0cdd910
# ╟─acda8937-b591-4599-840b-34cd0267339b
# ╟─f07c5a3d-d943-458c-abfb-4a57b879f4a6
# ╟─86fe4f73-50bb-4ea1-b27f-503e65c3d4d9
# ╟─e151799d-08a6-45e2-b418-6beca872f77e
# ╟─45a2aacc-e87e-4aee-bd31-3592c05f2671
# ╟─714a3b0e-38fe-43d2-a143-578aecb334ad
# ╟─c4579334-c101-49af-843b-1ef06609234a
# ╟─ced1bfbf-768e-4322-915d-4e3ace4aae1e
# ╟─08c27c82-a6aa-47ce-ad6a-ead9cc896a36
# ╟─a7b5bb62-1f02-462b-b5d9-f5ba3f96452c
# ╟─8200d22c-d30c-4033-8882-1a5f4b1267f1
# ╟─24218513-7452-49f8-8007-b281b57d8a21
# ╟─eaa76efa-1a9b-4c0b-bb57-b24646e82ad2
# ╟─0f51d8a4-eef7-48b3-b7dd-16fe0b357d7e
# ╟─c13779ca-df51-46b6-b8d0-35266bcf1b42
# ╟─a270eda4-1676-4dd4-90d4-ef84724aed47
# ╟─a1e06127-098d-470a-a5d2-b3d54165d820
# ╟─f13f89cf-c3ed-47b1-8e99-f14d0432f68d
# ╟─33872352-c2f4-4f1c-a0e6-d4fbc22b3038
# ╟─c94c665f-88ed-4be8-8a77-1644ca0eb828
# ╟─554ed557-ac54-4599-be94-ff42706adec3
# ╟─7b608577-71fd-4518-ae94-ca8587f0a82b
# ╟─03da8abc-4973-4781-8b1f-372f75bb0d03
# ╟─49656330-8647-40de-b43c-26fed8edbae9
# ╟─1e0baca0-d910-4dcf-97f4-4a1107a330b4
# ╟─2e9c9bb6-719a-4703-9a40-d0a5a6f46066
# ╟─aff83ff4-6f97-4865-a77c-522fd78d87c0
# ╟─eafd1404-d88b-4b23-8385-c8540dd17552
# ╟─06430c95-795e-4334-8a83-2034136349b7
# ╟─8e1f9c3d-8dc6-432b-8794-da8691a77c28
# ╟─8b8065a9-0b1b-4618-9051-5cfea7eed01b
# ╟─4202d79d-6c18-4114-8f38-d0a4a700508c
# ╟─9a3d1747-dd2f-4634-8552-618b7cdefc88
# ╟─59985e84-56f4-420c-90e7-f20d9dd41fdf
# ╟─c59d7b00-8d49-42c5-bd75-dedaf9d43a3e
# ╟─c7609399-28b0-4138-a248-6bf6e4185655
# ╟─eab2d2e3-9fbe-4cc7-9a04-b1dd74cbc208
# ╟─179c4b66-b7b8-408e-9f6e-d3a257f30f6b
# ╟─59260217-2db5-473a-8801-4446343dabb4
# ╟─c499aa0c-e37a-4012-bd21-d4a25e192be6
# ╟─7aa8a914-928a-4bc7-8a04-8509f80d718f
# ╟─8089e64c-705c-4f04-9ea1-fe9dfdacd980
# ╟─714a4fc6-a76a-4d69-823d-057791dda148
# ╟─4a51f1ac-06f0-42af-ba8f-ac7d1d732966
# ╟─05d19cdb-f859-4da8-861f-01d9a8a936f7
# ╟─c67d4817-b345-440c-93b4-584ddf0eec0e
# ╟─6c502b38-5061-485a-a219-2fe7488d0f71
# ╟─21a1456f-8ef1-4e0e-8680-41f923f364d5
# ╟─3882b14f-7ba0-4b48-b3fa-1ed7f0aa2808
# ╟─1975c1f0-0885-4fea-8c1e-8a8b36fc28ac
# ╟─4c8c68ab-195c-488f-8b9f-aa97f7378dc1
# ╟─dc5248ba-4e93-495d-ad62-a3051d53aad0
# ╟─d2825fe6-901a-48ba-a7d0-96cf91928bff
# ╟─c02abf1c-b782-4ce8-8847-4f98e2d0fff3
# ╟─b810ed45-7680-4ab1-83f6-9206fa267bdf
# ╟─0049e282-c3d7-478d-ba18-b79108490ec8
# ╟─4b1f1c1a-8943-4edb-9f56-ed95086e4861
# ╟─8e700fde-e2f9-449f-bd74-564af939d387
# ╟─cdfa5440-90e9-41e5-ac45-6db6081bde48
# ╟─d9c88050-3a34-4c26-96cf-d9e5f0bf9b66
# ╟─d7d3eae4-b1fa-418f-a907-0c819410a694
# ╟─a83e02b9-776e-426e-98c1-03d95781a357
# ╟─4506af8a-6a64-4e96-aa81-021979a3ded2
# ╟─14cc3a2e-7e23-4bd3-8476-208d2f19a500
# ╟─25e0b6ce-9863-476c-8b49-04042e8037bc
# ╟─65f772c0-2daf-4676-9397-8787ba22dfb4
# ╟─700876a3-6e1d-4a45-86d5-f1edcef2d8e5
# ╟─cff6bfa5-b56d-4210-98fe-d0e08e380189
# ╟─19216db0-e54a-4f94-b452-28d56f670eb9
# ╟─a9a1fa37-000c-46e1-b529-ce8aa964a48e
# ╟─92399c76-2da5-404e-b3fd-e136a95a5590
# ╟─c25aaf38-8878-4fc3-95a5-3673a7bc9851
# ╟─7db62ef0-0d0e-4255-b7ff-66edd382ddd9
# ╟─fc111ca8-46b7-46be-94e1-e26e80cf626e
# ╟─2e343571-a587-4ae5-a855-230e9ea3d67d
# ╟─2f9dab49-3257-4ff6-aa0c-c2185cffaa89
# ╟─34d28786-b3ed-41ef-b50b-6554ba01cecd
# ╟─0cc86cd8-b6eb-4165-830a-2c47560dcb81
# ╟─7d39dd1b-af1b-471c-adb4-22195179cadc
# ╟─a0206df4-dbde-4ee8-b3f2-a655080c0c93
# ╟─fdb6864f-68d0-43c6-86fe-d507d2169d3a
# ╟─e3c09b6e-995c-4ca6-9953-af08249f2c95
# ╟─87f2e8e4-f10e-4e7b-81f3-ba303c7fa17b
# ╟─4a4880a5-3087-428e-850e-d9cbf71c01e8
# ╟─0d35a79d-b525-4f8a-9afd-02c4bcec2ffc
# ╟─2b3e2eb5-304a-4d4b-a658-0b5d4d8c1995
# ╟─db7731fc-a4d1-41bb-b478-8ee8ff0fc9a0
# ╟─ec46999c-1974-4164-a8ec-82a6cbadba31
# ╟─f3b75bd7-98c9-44a6-bf83-0e7825ed53df
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
