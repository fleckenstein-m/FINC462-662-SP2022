### A Pluto.jl notebook ###
# v0.17.2

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

# ╔═╡ da5a744d-93f5-4e12-85fc-394348e9a60b
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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Bond Pricing</b> <p>
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
<input type="checkbox" value="">Calculate the price of a Treasury note/bond.<br><br>
    <input type="checkbox" value="">Know what the yield to maturity of a bond is.<br><br>   
	<input type="checkbox" value="">Price securities using the observed prices of other securities and the Law of One Price.<br><br>
	    <input type="checkbox" value="">Construct an arbitrage trade if the Law of One Price is violated.<br><br>
	</fieldset>      
	"""
end

# ╔═╡ f2c1ef60-f121-433a-9965-32ec75793d13
TableOfContents(aside=true, depth=1)

# ╔═╡ 7de98c17-58c5-44f4-bbb9-ebb90d704c60
md"""
## Pricing Treasury Notes/Bonds
"""

# ╔═╡ cbaead68-2cad-48a2-b86d-d1748e6610b3
md"""
- In the last lecture, we covered the "building blocks" (annuities, perpetuities, compounding) which we will now use to price bonds
- Our focus is on fixed coupon **Treasury notes/bonds** without option-like features.
- Unless otherwise noted, coupon interest is paid semi-annually
- We are going to assume that Treasury bonds have no credit risk.
"""

# ╔═╡ 03721413-19f4-4a0c-b61f-9d8ee5a68848
md"""
##
"""

# ╔═╡ aac27a3c-e90a-437f-a563-f81d41c8d3f7
LocalResource("./TreasuryNoteDescrExampleBloomberg.png",:width => 1200) 

# ╔═╡ f69c3712-7f40-4821-bbc0-05b1472b9ba2
md"""
##
"""

# ╔═╡ 13102a49-65b2-4b14-824c-412894cf2a95
LocalResource("./TreasuryNoteCashflowExampleBloomberg.png",:width => 1200) 

# ╔═╡ ca22f244-2e4e-4719-a935-a5d5fc5fece2
md"""
## Example
"""

# ╔═╡ 2293d075-6ea9-4757-9921-3251f9bab67b
md"""
#### Set Coupon Rate
"""

# ╔═╡ de693798-22a3-4e42-936a-372b3b67b77e
@bind C Slider(0:0.1:10.0, default=2.5, show_value=true)

# ╔═╡ 46636299-a67a-438b-aedd-d31b13fb696d
md"""
Coupon Rate: $(C)%
"""

# ╔═╡ 76e22a68-2f69-4715-adbd-c89c51d08415
md"""
#### Set Time to Maturity
"""

# ╔═╡ 5ea2d792-1ddd-477c-b5e2-ac1a73d90499
@bind T Slider(1.0:1:10.0, default=5.0,show_value=true)

# ╔═╡ 6de1c5cd-aa93-4124-b746-880b89d40a96
md"""
Time to Maturity: $(T) years
"""

# ╔═╡ ac0dc7f7-57df-4bc3-abf9-1deca96420f4
Markdown.parse("
Using a par value of \\\$100, the semi-annual coupon cash flow is:
``C=\\frac{$C \\%}{2} \\times \\\$$(roundmult( 100.0,1e-6))= \\\$$(roundmult( C/200*100,1e-6))``
")

# ╔═╡ 0924235f-1e63-40ea-9b8f-b0625f68f8cf
begin
	CF = 0.5*C.*ones(convert(Int64,T*2))
	CF[end] += 100
	CT = zeros(convert(Int64,T*2))
	CT[end] = 100
	dt = collect(0.5:0.5:T)
	bar(dt,CF,label="", ylim=(0,120), xlim=(0,T+1), xticks=collect(0.0:0.5:T), xlabel="Years", ylabel="Coupon Cash Flow")
	bar!(dt,CT,c=:green,label="")
end

# ╔═╡ 6fa0988b-6c1a-4721-a008-3f0d4ea0ec2f
md""" 
## Valuing Treasury notes/bonds
- To calculate the price $P$ of a Treasury note/bond, we need to calculate the present values (PV) of 
  - all coupon cash flows
  - and the principal cash flow at maturity

$$P = \textrm{PV(Coupon cash flows)} + \textrm{PV(Par value)}$$
"""

# ╔═╡ baf04d40-9d5e-424b-8dd2-e11744aa4e8c
md"""
## Example
"""

# ╔═╡ 8a9d819e-d308-4a36-8c5b-168e838f95ba
@bind bttn_2 Button("Reset")

# ╔═╡ ef7ad171-1214-4d24-ba00-759b4cf00e5a
begin
bttn_2
	md"""
	- Face Value $F$ [$]: $(@bind F2 Slider(100:100:10000, default=100, show_value=true))
	- Coupon Rate $c$ [% p.a.]: $(@bind c2 Slider(0:0.125:10, default=2, show_value=true))
	- Discount rate $r$ [% p.a.]: $(@bind r2 Slider(0:0.125:16, default=4, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T2 NumberField(0:1:10,default=3))
	"""
end

# ╔═╡ 900773e3-91bb-439d-baf4-48fd3cb75878
md"""
- To illustrate, suppose we want to calculate the price of a 3-year Treasury note (``T=``$T2) with coupon rate ``c=`` $(c2)``\%`` (paid semiannually) and principal amount (face value) of ``F=`` $ $F2. 
- Assume that the discount rate ("interest rate") is ``r=6``% per annum (semi-annually compounded).
"""

# ╔═╡ dde97f2c-7267-4560-8bcf-2c21c6593525
begin
	C2 = (c2/200)*F2
	CF2 =C2.*ones(convert(Int64,T2*2))
	CF2[end] = CF2[end] + F2
	CT2 = zeros(convert(Int64,T2*2))
	CT2[end] = copy(F2)
	dt2 = collect(0.5:0.5:T2)
	PV2 = CF2./(1+r2/(2*100)).^(2 .* dt2)
	PV2total = sum(PV2)
	
	bar(dt2,CF2,label="", ylim=(0,CF2[end]+50), xlim=(0,T2+1), xticks=collect(0.0:0.5:T2), xlabel="Years", ylabel="Coupon Cash Flow")
	bar!(dt2,CT2,c=:green,label="")
end

# ╔═╡ 26894a8b-8a2f-45ba-9d8c-90a70dc3ad48
md"""
##
"""

# ╔═╡ 01e3630b-a039-4496-afe2-939bc9d3037b
md"""
- The cash flows are
"""

# ╔═╡ fcab9aaa-e950-4d88-a800-bdecffd7c315
begin
	tmpStr2 = Vector{String}()
	for idx=1:length(CF2)
	 	push!(tmpStr2,"$(CF2[idx]) * 1/(1+$r2%/2)^(2*$(dt2[idx]))=$(roundmult(PV2[idx],1e-4))")
	end
	tmpStr22 = string(roundmult(PV2[1],1e-4))
	for idx=2:length(CF2)
		global tmpStr22 = tmpStr22 * " + " * string(roundmult(PV2[idx],1e-4))
	end
	tmpStr22 = tmpStr22 * " = " * string(roundmult(PV2total,1e-6))
	
	df = DataFrame(Time=dt2,CashFlow=CF2,PresentValue=PV2,Calculation=tmpStr2)
end

# ╔═╡ 48e16cc0-14f6-4390-8fc4-7feafd004e28
md"""
Present Value = $(tmpStr22)
"""

# ╔═╡ e5c1693f-9013-407b-ba1f-83e1aabd271c
md"""
## Shortcut using the annuity formula
"""

# ╔═╡ 245dccfb-d163-43a8-b83b-ee2c0c787bc4
md"""
- As the time to maturity $T$ increases, manually calculating all present values becomes tedious.
- Instead, we can use the annuity formula.
"""

# ╔═╡ b4778bc3-c6f8-49da-a00d-b5a9edf2161e
md"""
## Present Value of Annuity
"""

# ╔═╡ e418ffd8-7b8d-4d73-8569-ac3e6056338d
md""" 
!!! recall

The present value today (time $t=0$) of an annuity paying a dollar cash flow of $C$ for $T$ years is

$$\textrm{PV} = \left( \frac{C}{r} \right) \left(1 - \frac{1}{(1+r)^{T}} \right)$$

Time $\,t$    | 0   | 1  | 2 | 3 | 4 | ... | T | T+1 | ...
:------------ | :-- |:-- |:--|:--|:--|:--|:--|:--|:--|
Cash Flow     | 0   | $C$  | $C$ | $C$ | $C$ |...|$C$|0|0

"""

# ╔═╡ bc09388d-e144-4f5a-b8d4-71a3f354bf22
md"""
##
"""

# ╔═╡ a0069452-0059-4c7e-b7e6-8a5ecc22b8aa
md"""
- We can use the annuity formula to calculate the present values of all coupon cash flows.
- To calculate the bond price, we need to add the present value of the principal cash flow.
- First, the terms in the annuity formula are 
  - ``C``=$(CF2[1])
  - ``T``=$(T2), 
  - ``r``=$(r2)
- Second, the present value of the principal amount is $$F/(1+\frac{r}{2})^{2T}$$
- The sum of these two is the bond price $P$.
$$P = \frac{C}{r/2} \left(1- \frac{1}{\left(1+\frac{r}{2} \right)^{2 T}} \right) + \frac{F}{(1+\frac{r}{2})^{2T}}$$
"""

# ╔═╡ 1b8aaccd-0a98-47bb-bb06-dc5818439d91
md"""
## Price of a semi-annual coupon bond
"""

# ╔═╡ 089df1ad-cd33-44a7-bb0d-aaae86395f32
md""" 
!!! important

The price $P$ of a $T$-year bond with principal value $F$ paying semi-annual coupon interest at an annual rate of $c$ (semi-annual cash flows of $C=c/2\times F$) and semi-annually-compounded discount rate $r$ is

$$P = \frac{C}{r/2} \left(1- \frac{1}{\left(1+\frac{r}{2} \right)^{2 T}} \right) + \frac{F}{(1+\frac{r}{2})^{2T}}$$

Time $\,t$    | 0   | 0.5  | 1 | 1.5 | 2 | ... | T | 
:------------ | :-- |:-- |:--|:--|:--|:--|:--|
Cash Flow     | 0   | $C$  | $C$ | $C$ | $C$ |...|$C+F$|

"""

# ╔═╡ f4ad4c46-e7a0-4dee-80a1-b09e32bff970
Markdown.parse("
``\$P = \\frac{C}{\\frac{r}{2}} \\left(1- \\frac{1}{\\left(1+\\frac{r}{2} \\right)^{2 T}} \\right) + \\frac{F}{(1+\\frac{r}{2})^{2T}}=\\frac{$C2}{$(r2/200)} \\left(1- \\frac{1}{\\left(1+$(r2/200) \\right)^{2 \\times $T2}} \\right) + \\frac{$F2}{(1+$(r2/200))^{2\\times $T2}}=$(roundmult(C2/(r2/200)*(1-1/(1+r2/200)^(2*T2))+F2/(1+r2/(200))^(2*T2),1e-6))\$
``")

# ╔═╡ 37ff7040-7fc6-4307-9dcb-6d2d8b337919
md"""
## Valuing Zero-coupon bonds
"""

# ╔═╡ e62f0284-726d-47ed-872b-bb31fa4f3735
md"""
- A zero coupon bond has one single cash flow at maturity $T$.
"""

# ╔═╡ 3aa7bf1e-a1f2-4d5d-9ae0-5e05956b622c
md"""
## Example
"""

# ╔═╡ d64c7c3d-589f-46f1-9274-3ad512e0bc58
@bind bttn_3 Button("Reset")

# ╔═╡ 852663bb-8e3d-49a1-a4c3-4ca9b6783173
begin
bttn_3
	md"""
	- Face Value $F$ [$]: $(@bind F3 Slider(100:100:10000, default=100, show_value=true))
	- Discount rate $r$ [% p.a.]: $(@bind r3 Slider(0:0.125:16, default=4, show_value=true))
	- Time to maturity $T$ [years]: $(@bind T3 NumberField(0:1:10,default=3))
	"""
end

# ╔═╡ 509479fc-0d0b-41d2-9afc-9cfa8260441e
begin
	CF3 = zeros(convert(Int64,T3*2))
	CF3[end] = F3
	dt3 = collect(0.5:0.5:T3)
	bar(dt3,CF3,label="", ylim=(0,F3+20), xlim=(0,T3+1), xticks=collect(0.0:0.5:T3), xlabel="Years", ylabel="Coupon Cash Flow")
end

# ╔═╡ 17abb35b-9c49-47e3-a91d-735be805cc9c
md"""
- To value a zero-coupon bond, we need to compute the present value of the single principal cash flow at maturity $T$.
"""

# ╔═╡ 45a33440-eb55-4ba3-acd0-c7212740d5f5
md"""
## Price of a zero-coupon bond
"""

# ╔═╡ 3fb68955-17b5-445b-b730-e03ebd9cd5b9
md""" 
!!! important

The price $P$ of a $T$-year zero-coupon bond with principal value $F$ and annually-compounded discount rate $r$ is

$$P = \frac{F}{(1+r)^T}$$

With semi-annually-compounded discount rate $r$, the price of the zero-coupon bond is

$$P = \frac{F}{(1+\frac{r}{2})^{2\times T}}$$
"""

# ╔═╡ eeefda13-0232-4099-a3d7-39feb0981dd3
md"""
## Example: Price of Zero-Coupon bond
"""

# ╔═╡ 5f9f0e26-e4b0-400b-a356-5644a7f30778
md"""
- Continuing with the example from above and assuming that the discount rate $r$ is semi-annually compounded, the price $P$ of a T=$T3 year zero-coupon bond with face value of $F3 is
"""

# ╔═╡ 8744b92a-e398-4a54-b0d5-bae1cbfe53e4
Markdown.parse("
``\$P = \\frac{F}{(1+\\frac{r}{2})^{2\\times T}} = \\frac{$F3}{(1+\\frac{$(r3/100)}{2})^{2\\times $T3}}=$(roundmult(F3/(1+r3/100)^(2*T3),1e-6))
\$
``")

# ╔═╡ a93d3a56-7269-4e19-a69b-cd4e4c5956c3
md"""
# Yield to Maturity
"""

# ╔═╡ 4f296087-be3f-484f-bc90-ed4c6366a728
md"""
- Thus far, the discount rate $r$ was given.
- Suppose now that we observe the bond price $P$, but are not given the discount rate.
- We can use the bond price $P$ to calculate what discount rate--call it $y$--the bond price implies.
- In other words, we ask what discount rate investors are using to arrive at the bond price.
- This discount rate $y$ is referred to as the **yield to maturity** of the bond.
"""

# ╔═╡ 128c46ec-8290-4fdc-b722-dbaafb653dda
md"""
##
"""

# ╔═╡ 66ba0b24-1892-4a88-b201-21c4aa702033
md"""
## Yield to Maturity of a Zero-Coupon bond
"""

# ╔═╡ c2f5a9cf-18a4-42cb-a085-1e297ca39047
md"""
##
"""

# ╔═╡ e40b4455-9b6f-446e-ae4b-7b974bcf4f10
md"""
- We first write down the equation for the price of the zero-coupon bond.
- Then, we set the price equal to the market price and solve for the yield $y$.
$$P = \frac{F}{(1+y)^T}$$ 
"""

# ╔═╡ 09242936-990c-4448-a698-7113c347a830
begin
	F4 = 100
	P4 = 90
	T4 = 3
	md""" 
	Thus, the yield on the zero coupon bond is $(roundmult( ((F4/P4)^(1/T3)-1)*100,1e-6)) percent (annually compounded).
	"""
end

# ╔═╡ c82619ca-a8a3-42c4-92d6-6cfa53640e8f
md"""
- Let's first consider a zero-coupon bond (face value 100) with maturity in T=$T4 years.
- Suppose the market price of this zero-coupon bond P=$P4
- What is the market-implied discount rate $y$ (annually-compounded)? 
- This is the **yield to maturity**.
"""

# ╔═╡ 0e34c082-2899-46e0-b755-644ce1393fe1
Markdown.parse("
``\$$P4=\\frac{$F4}{(1+y)^$T4} \\rightarrow (1+y)^3 = \\frac{100}{90} \\rightarrow (1+y) = \\left(\\frac{$F4}{$P4} \\right)^{(1/3)} \\rightarrow y=$(roundmult( (F4/P4)^(1/T3)-1,1e-6))=$(roundmult( ((F4/P4)^(1/T3)-1)*100,1e-6))\\%\$``
")

# ╔═╡ 5d5db47f-28b4-47a6-828e-8c7ca51e4420
md"""
##
"""

# ╔═╡ a2078829-1c7e-430a-96e8-3177726dda88
md"""
## Yield to Maturity of a Treasury Note/Bond
"""

# ╔═╡ 94ce62c7-34d2-4a88-a42d-3155e673d688
md"""
- Next, let's consider a Treasury note/bond paying semi-annual coupon interest.
- To start, we can apply the same approach as in the case of the zero-coupon bond.
- To illustrate, we use the Treasury note (``T=``$T2) with coupon rate ``c=`` $(c2)``\%`` (paid semiannually) and principal amount (face value) of ``F=`` $ $F2 from the previous example. 
- Assume that the Treasury note has a price of \$ $(roundmult(PV2total,1e-6)).
"""

# ╔═╡ 8184bbc5-1641-40d0-86e7-8550aed8e4bf
Markdown.parse("
``\$P = \\frac{C}{\\frac{y}{2}} \\left(1- \\frac{1}{\\left(1+\\frac{y}{2} \\right)^{2 T}} \\right) + \\frac{F}{(1+\\frac{y}{2})^{2T}}\$
``")

# ╔═╡ a2a93974-0f4d-43ca-9284-eb97ca998516
Markdown.parse("
``\$$(roundmult(PV2total,1e-6))=\\frac{$C2}{y/2} \\left(1- \\frac{1}{\\left(1+\\frac{y}{2}\\right)^{2 \\times $T2}} \\right) + \\frac{$F2}{(1+\\frac{y}{2})^{2\\times $T2}}\$``
")

# ╔═╡ 9e1381e3-12ad-440e-8895-1d3a4dbae2f1
md"""
##
"""

# ╔═╡ 7a24abdb-a706-4254-bf39-7c4440a7bb19
LocalResource("./TreasYieldToMaturity_01.png",:width => 1200) 

# ╔═╡ 2699840b-172a-43ab-9191-1404ff09965a
LocalResource("./TreasYieldToMaturity_03.png",:width => 1200) 

# ╔═╡ 052fb980-f438-49aa-ad09-fd45eb63cc42
LocalResource("./TreasYieldToMaturity_02.png",:width => 1200) 

# ╔═╡ 42481e5e-ad91-4079-8dd3-f295a8e8b390
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and look up a Treasury Note/Bond as we have discussed before.
>  - Next, from the `DES` page (first screenshot above) type `YAS` on the keyboard and press enter.
>  - This will open a screen as shown in the middle screenshot.
"""

# ╔═╡ f7dc15ac-1763-4815-b8b1-1183eb018ba1
md"""
- We need to find the value for $y$ such that the right hand side of the equation is equal to $(roundmult(PV2total,1e-6)).
- It turns out that we cannot easily solve for $y$, and that we need to use a numerical method.
- Excel and financial calculators have functions that can calculate the yield to maturity.
- Let's illustrate how these function work.
- Essentially, it is by trial-and-error. We pick a value for $y$ and change it until the right hand side is equal to the price of $(roundmult(PV2total,1e-6)).
"""

# ╔═╡ dbed3e23-83e3-424b-9a9d-d1da06cf8a6d
@bind bttn_4 Button("Reset")

# ╔═╡ 3e779514-c5e2-48a4-970c-0bf3ac9d75bb
begin
bttn_4
	md"""
	- Discount rate $y$ [% p.a.]: $(@bind y4 Slider(0:0.00001:10, default=4, show_value=true))
	"""
end

# ╔═╡ af1d20f0-1b7d-4137-bfa7-ec010c18e648
Markdown.parse("
``\$$(roundmult(PV2total,1e-6)) =\\frac{$C2}{\\frac{$(roundmult(y4/100,1e-4))}{2}} \\left(1- \\frac{1}{\\left(1+\\frac{$(roundmult(y4/100,1e-4))}{2} \\right)^{2 \\times $T2}} \\right) + \\frac{$F2}{(1+\\frac{$(roundmult(y4/100,1e-4))}{2})^{2\\times $T2}}=$(roundmult(C2/(y4/200)*(1-1/(1+y4/200)^(2*T2))+F2/(1+y4/(200))^(2*T2),1e-6))\$
``")

# ╔═╡ 650d22a2-49f8-4c97-931c-877e00b4a9b0
md"""
##
"""

# ╔═╡ 33c13b61-ae9c-42fa-b553-7a40bb394b15
md"""
- By varying the discount rate $y$, we find that the right-hand side is equal to the price of $(roundmult(PV2total,1e-6)) when the discount rate is y = $r2%.
- This is the bond's yield to maturity.
"""

# ╔═╡ 3cef08cc-50f8-4662-82c9-7016fca91bb6
md"""
##
"""

# ╔═╡ 055e980e-942a-4f02-9806-6060fe72ff52
md"""
- To summarize, the yield to maturity $y$ is the discount rate that will make the present value of the bond's cash flows equal to its price.
- We can think of the yield to maturity as the "return" an investor earns by buying the bond today at its market price and holding it until maturity of the bond.
  - We can also think of the yield to maturity as the internal rate of return (IRR) of the bond.
- The yield to maturity is specific to each bond (i.e. we take a bond and calculate the yield to maturity of this specific bond). Do not simply use the yield to maturity you calculated for one bond and use it to get the price of a different bond
- Note that the yield-to-maturity has limitations as a measure of "return".
- Consider the following example.
"""

# ╔═╡ 737f45ef-4d9e-4381-a6df-96886733ddd2
md"""
## The “Sleeping Beauty” Bond
- On July 21, 1993, Disney issued a 100-year bond
- They sold $300,000,000 worth of debt at an annual yield of 7.55%.
- For reference, the 30-year Treasury bond yield was approximately 6.6% at that time.
- Their bond was graded AA.
- Disney has an option to call or redeem the bonds beginning July 15, 2023 at 103.02% of their face value.
- A lot of interest from pension funds, insurance companies and other institutional investors
"""

# ╔═╡ 71e0133d-e4db-41af-991a-8c7c8b577f3c
md"""
##
"""

# ╔═╡ c9c4b2f3-7256-4462-a260-38c6a5783e9f
LocalResource("./DisneyBond.png",:width => 1200) 

# ╔═╡ 3ac4c6f0-a147-4558-af4f-bb95fa4b6eb3
md"""
## Yield to maturity in Excel
"""

# ╔═╡ 1df82d1c-b99d-4fc3-91d6-5457562db644
md"""
- We are given a 3-year Treasury note with a coupon rate of $c=4%$ (paid semi-annually) with a face value F=\$1,000. 
- The market price of the Treasury note is P=\$1,029.17,
- Let's calculate the yield to maturity.
- In Excel, we can do this with the function `YIELD`.

"""

# ╔═╡ 9c141b09-02fa-44c7-97e6-2c237b03863e
md"""
##
"""

# ╔═╡ ada659cd-9686-4c9a-910d-7dafc9a26dcd
md"""
- In order to use this function, we need to provide the following:
  - The current date (can be arbitrary). Let's pick January 1, 2020.
  - The maturity date (in the example, the maturity date has to be 3 years after the current date). Let's pick January 1, 2023.
  - The coupon rate, expressed as an annual rate in decimals.
  - The bond price per $100 par value (in the example, it is $102.917).
  - The principal value $100.
  - The number of times interest is compounding during the year (for semi-annual bonds, this number is 2).
- Thus, writing in an Excel cell: `=YIELD(DATE(2020,1,1),DATE(2023,1,1),0.04,102.917,100,2)`
- The result is: `2.9765%`
- For more information on this Excel function, see [Yield Function](https://support.microsoft.com/en-us/office/yield-function-f5f5ca43-c4bd-434f-8bd2-ed3c9727a4fe?ns=excel&version=90&syslcid=1033&uilcid=1033&appver=zxl900&helpid=xlmain11.chm60490&ui=en-us&rs=en-us&ad=us)
"""

# ╔═╡ 3d48cc60-8a3d-4adf-9bcc-ff594f82b867
md"""
##
"""

# ╔═╡ 84bc02a1-6df7-4462-b023-0a736dffc558
md"""
- Let's verify whether Excel calculated the yield to maturity correctly.
- We know that the yield to maturity is the discount rate $r$ that sets the present value of the bond's coupon cash flows equal to its market price.

$$P = \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 1.0}} + \ldots + \frac{C+100}{\left(1+\frac{r}{2}\right)^{2\times T}}$$

- Plugging in the numbers using $C=0.04/2\times 1000=40$ and $T=3$, the right hand side is equal to

$$\frac{20}{\left(1+\frac{2.9765\%}{2}\right)^{2\times 0.5}} + \frac{20}{\left(1+\frac{2.9765\%}{2}\right)^{2\times 1.0}} + \ldots + \frac{20+1000}{\left(1+\frac{2.9765\%}{2}\right)^{2\times T}}=1029.17$$

- Indeed, this matches the market price $P=$ \$ $1029.17$.
"""

# ╔═╡ 88cbf89d-5961-4734-abe4-cc2143ccd21a
md"""
# Law of One Price and Pricing by Replication
"""

# ╔═╡ 1a8891f8-c631-4399-ae2e-1c1402c16944
md"""
> The law of one price says that all portfolios with the same payoff have the same price.
> (Principles of Financial Economics, by Stephen F. LeRoy)
"""

# ╔═╡ f0c50470-fbc1-46f2-9c61-11c57840d17f
md"""
##
"""

# ╔═╡ e5b9685e-2f6d-429d-a9e1-322952cc86d6
md"""
- We will use this fundamental idea to price bonds and other securities.
- To illustrate the concept, suppose there are three bonds A, B, and C.
- Suppose we do not know the price of bond C, but that we know the price of A and B.
- Assume that when we buy both bond A and bond B, the resulting coupon/principal cash flows are the same as those of bond C.
- Then, it must be true that the price of bond C is the same as the sum of the price of bond A and bond B.
"""

# ╔═╡ d85d9910-c3be-4b47-8dce-16ed63e2b1ad
md"""
## Example
"""

# ╔═╡ 89f679f4-eacc-4a8d-962e-d182927b0751
md"""
- Consider two portfolios
"""

# ╔═╡ 2d3f36ba-c528-4a96-b043-445c5b5496cd
begin
	Ct1=25
	Ct2=50
	
	At1=1*Ct1
	At2=0
	
	Bt1=0
	Bt2=1*Ct2
	
	PA=24
	PB=44
	multA = Ct1/At1
	multB = Ct2/Bt2 
	PC=multA*PA+multB*PB
	display("")
end

# ╔═╡ 64dd492b-6081-4823-9c23-fd437e5b9e8a
TwoColumn(
	md"""
### Portfolio 1
Security      | Payoff $t$=1   | Payoff $t$=2  
:------------ | :--------------|:-----------
C             | $Ct1           | $Ct2
	""",
	md"""
### Portfolio 2
Security      | Payoff $t$=1   | Payoff $t$=2  
:------------ | :--------------|:-----------
A             | $At1           | $At2
B             | $Bt1           | $Bt2
	"""
)

# ╔═╡ c6e2b840-812f-46f3-a893-4722288fd97b
md"""
##
"""

# ╔═╡ a0d04824-dbe9-48e0-8645-dfc04c34d402
md"""
Suppose that the price of A is \$$PA and the price of B is \$$PB. What is the
price of C?
"""

# ╔═╡ 3b1b4d48-43f5-4148-80dd-e5ae70ac3a7c
Markdown.parse("
!!! hint
    - Security C has the same cash flows as $multA of A and $multB of B combined.
    - Thus, its price must be the sum of  $multA times the price of A plus $multB times the price of B.
    - Price C = $multA * Price A + $multB * Price B = $multA * $PA + $multB * $PB = $(PC)
")

# ╔═╡ f0aaab55-ed47-4349-9a17-885318c7291d
md"""
##
"""

# ╔═╡ 33169b69-9f15-4257-b70d-14fbaf2ca25c
md"""
- Next, suppose that the price of C is 70.
- This is a violation of the law of one price. We can take advantage of this and earn an **arbitrage** profit.
- We do this by buying the security that costs less and short-sell the security that costs more.
- We earn a riskfree profit by doing so.
"""

# ╔═╡ a4f9c476-3037-435d-b32f-a4e8dfba628d
md"""
# Short-selling
"""

# ╔═╡ 927e5d42-df49-4638-a3a6-907886eb79fe
md"""
- To illustrate this concept, let's consider again the securities A, B, and C from the previous example.
- Let's also suppose that we observe prices on all three securities.
"""

# ╔═╡ f6a5d1fd-2f2c-43ec-94d5-ff781ed5064e
TwoColumn(
	md"""
### Portfolio 1
Security      | Price          |  Payoff $t$=1  | Payoff $t$=2  
:------------ | :--------------| :--------------|:-----------
C             | 71             | $Ct1           | $Ct2
	""",
	md"""
### Portfolio 2
Security      | Price          |  Payoff $t$=1  | Payoff $t$=2  
:------------ | :--------------| :--------------|:-----------
A             | $PA            | $At1           | $At2
B             | $PB            | $Bt1           | $Bt2
	"""
)

# ╔═╡ df34ca45-c908-4149-ae08-614931b9bc48
md"""
- Portfolio 1 (Security C) is too expensive, so we **short-sell** it.
- Short-selling involves borrowing a security and selling it at the market price.
"""

# ╔═╡ dd288a98-4a26-4e50-a36d-edf4ff3b7bb6
md"""
##
"""

# ╔═╡ 2e82b832-0217-4a7b-906f-58a10e75eceb
md"""
1. Borrow Security C
Assets           | Liabilities       |  
:------------    | :-----------------| 
Security C, \$71 | Security C, \$71  | 

2. Sell Security C on the market and get $71 in cash
Assets           | Liabilities       |  
:------------    | :-----------------| 
Security C, \$0  | Security C, \$71  | 
Cash C,     \$71 |                   | 

3. Use part of the cash to buy securities A and B (which cost $PA + $PB = $(PA+PB))
Assets            | Liabilities       |  
:------------     | :-----------------| 
Security C, \$0   | Security C, \$71  | 
Cash C,     \$3  |                   | 
Security A, \$$PA |   | 
Security B, \$$PB |   | 

"""

# ╔═╡ ba8b569b-cdf3-455d-b756-febd2065e4b3
md"""
##
"""

# ╔═╡ 09d8bd33-957c-49a2-85e1-07075ec6e160
md"""
- What are the resulting cash flows?

Position          | $t$ = 0 (today) | $t$ = 1        | $t$ = 2  
:------------     | :-------------- | :--------------|:---------------
Buy 1 unit of A   | -$PA            | $At1           | $At2
Buy 1 unit of B   | -$PB            | $Bt1           | $Bt2
Short 1 unit of C | 71              | -$Ct1          | -$Ct2
------------------|-----------------|----------------|----------------
Total             | $(71-PA-PB)     | $(At1+Bt1-Ct1) | $(At2+Bt2-Ct2)
"""

# ╔═╡ b0150c24-7947-4766-be8b-5d51b7d79d89
md"""
- The difference $(71-PA-PB) is a riskfree arbitrage profit.
"""

# ╔═╡ 6599406d-679c-40b6-beac-02e16186b48f
md"""
## Practice Problem
"""

# ╔═╡ 15b0e762-2b20-4687-aedc-d07ea6ab7638
md"""
> 1. Is the Law of One Price satisfied here?
> 2. Construct a long-short strategy to take advantage of mispricing. 
"""

# ╔═╡ 2e4391fc-8d94-4b02-915b-a2499b7196b4
md"""
##
"""

# ╔═╡ 552421aa-c8a9-43c7-b43d-643d3bf22d85
TwoColumn(
	md"""
**Portfolio 1**
	
Security      | Price          |  Payoff $t$=1  | Payoff $t$=2  
:------------ | :--------------| :--------------|:-----------
C             | 45             | 25             | 25
	""",
	md"""
**Portfolio 2**
	
Security      | Price          |  Payoff $t$=1  | Payoff $t$=2  
:------------ | :--------------| :--------------|:-----------
A             | 48             | 50             | 0
B             | 45             | 0              | 50
	"""
)

# ╔═╡ 0ab19767-e8ee-4886-add4-4be7ee6449e2
md"""
##
"""

# ╔═╡ 006a8095-09cb-4090-8225-94a33eae3b3d
md"""
!!! hint
    1. It should be the case that A + B = 2 * C
	But, 2C = 90, so C is too cheap.

	2. Simply short A and B and buy C.
	That way, we get $3 today with no cash flows in the future.
"""

# ╔═╡ 0fab3a87-ea04-41f9-9ed6-2c690d8179b7
md"""
## CFA Practice Problem
"""

# ╔═╡ 1b42f143-abe1-462c-9aa8-402802f8897a
md"""
Consider the following two bonds that pay interest annually and suppose the discount rate is $r=4\%$

Bond          | Coupon Rate    |  Time-to-Maturity 
:------------ | :--------------| :--------------
A             | 5%            | 2 years
B             | 3%            | 2 years

- The price difference between Bond A and Bond B per 100 of par value is closest to:\
  a. 2.00\
  b. 3.77\
  c. 4.00\
"""

# ╔═╡ b9063748-0cc2-4639-b028-514e381685ff
md"""
!!! hint
    Write down the cash flows before making any calculations.
"""

# ╔═╡ 15f648a2-2217-47bf-b1dc-3e3529a7f07a
md"""
##
"""

# ╔═╡ 39a070d8-fb75-46b7-8029-9a38490a6f16
md"""
!!! hint
    Bond          | Cash flow t = 1 |  Cash flow t = 2
	:------------ | :---------------| :--------------
	A             | 5               | 105
	B             | 3               | 103
    --------------|-----------------|------------------
    Difference    | 2               | 2
    \
	- Thus, since the discount rate is 4%, the answer cannot be c. nor a.\
	- The answer must be b.\
    \
    - To confirm, just calculate the present value of the difference.
	
    $$\frac{2}{1+4\%} + \frac{2}{(1+4\%)^2} = 3.77$$
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
<input type="checkbox" value="" checked>Calculate the price of a Treasury note/bond.<br><br>
    <input type="checkbox" value="" checked>Know what the yield to maturity of a bond is.<br><br>   
	<input type="checkbox" value="" checked>Price securities using the observed prices of other securities and the Law of One Price.<br><br>
	    <input type="checkbox" value="" checked>Construct an arbitrage trade if the Law of One Price is violated.<br><br>
	</fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
# Reading 
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 2
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
deps = ["Libdl"]
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
# ╟─da5a744d-93f5-4e12-85fc-394348e9a60b
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─f2c1ef60-f121-433a-9965-32ec75793d13
# ╟─7de98c17-58c5-44f4-bbb9-ebb90d704c60
# ╟─cbaead68-2cad-48a2-b86d-d1748e6610b3
# ╟─03721413-19f4-4a0c-b61f-9d8ee5a68848
# ╟─aac27a3c-e90a-437f-a563-f81d41c8d3f7
# ╟─f69c3712-7f40-4821-bbc0-05b1472b9ba2
# ╟─13102a49-65b2-4b14-824c-412894cf2a95
# ╟─ca22f244-2e4e-4719-a935-a5d5fc5fece2
# ╟─2293d075-6ea9-4757-9921-3251f9bab67b
# ╟─de693798-22a3-4e42-936a-372b3b67b77e
# ╟─46636299-a67a-438b-aedd-d31b13fb696d
# ╟─76e22a68-2f69-4715-adbd-c89c51d08415
# ╟─5ea2d792-1ddd-477c-b5e2-ac1a73d90499
# ╟─6de1c5cd-aa93-4124-b746-880b89d40a96
# ╟─ac0dc7f7-57df-4bc3-abf9-1deca96420f4
# ╟─0924235f-1e63-40ea-9b8f-b0625f68f8cf
# ╟─6fa0988b-6c1a-4721-a008-3f0d4ea0ec2f
# ╟─baf04d40-9d5e-424b-8dd2-e11744aa4e8c
# ╟─ef7ad171-1214-4d24-ba00-759b4cf00e5a
# ╟─8a9d819e-d308-4a36-8c5b-168e838f95ba
# ╟─900773e3-91bb-439d-baf4-48fd3cb75878
# ╟─dde97f2c-7267-4560-8bcf-2c21c6593525
# ╟─26894a8b-8a2f-45ba-9d8c-90a70dc3ad48
# ╟─01e3630b-a039-4496-afe2-939bc9d3037b
# ╟─fcab9aaa-e950-4d88-a800-bdecffd7c315
# ╟─48e16cc0-14f6-4390-8fc4-7feafd004e28
# ╟─e5c1693f-9013-407b-ba1f-83e1aabd271c
# ╟─245dccfb-d163-43a8-b83b-ee2c0c787bc4
# ╟─b4778bc3-c6f8-49da-a00d-b5a9edf2161e
# ╟─e418ffd8-7b8d-4d73-8569-ac3e6056338d
# ╟─bc09388d-e144-4f5a-b8d4-71a3f354bf22
# ╟─a0069452-0059-4c7e-b7e6-8a5ecc22b8aa
# ╟─1b8aaccd-0a98-47bb-bb06-dc5818439d91
# ╟─089df1ad-cd33-44a7-bb0d-aaae86395f32
# ╟─f4ad4c46-e7a0-4dee-80a1-b09e32bff970
# ╟─37ff7040-7fc6-4307-9dcb-6d2d8b337919
# ╟─e62f0284-726d-47ed-872b-bb31fa4f3735
# ╟─3aa7bf1e-a1f2-4d5d-9ae0-5e05956b622c
# ╟─852663bb-8e3d-49a1-a4c3-4ca9b6783173
# ╟─d64c7c3d-589f-46f1-9274-3ad512e0bc58
# ╟─509479fc-0d0b-41d2-9afc-9cfa8260441e
# ╟─17abb35b-9c49-47e3-a91d-735be805cc9c
# ╟─45a33440-eb55-4ba3-acd0-c7212740d5f5
# ╟─3fb68955-17b5-445b-b730-e03ebd9cd5b9
# ╟─eeefda13-0232-4099-a3d7-39feb0981dd3
# ╟─5f9f0e26-e4b0-400b-a356-5644a7f30778
# ╟─8744b92a-e398-4a54-b0d5-bae1cbfe53e4
# ╟─a93d3a56-7269-4e19-a69b-cd4e4c5956c3
# ╟─4f296087-be3f-484f-bc90-ed4c6366a728
# ╟─128c46ec-8290-4fdc-b722-dbaafb653dda
# ╟─66ba0b24-1892-4a88-b201-21c4aa702033
# ╟─c82619ca-a8a3-42c4-92d6-6cfa53640e8f
# ╟─c2f5a9cf-18a4-42cb-a085-1e297ca39047
# ╟─e40b4455-9b6f-446e-ae4b-7b974bcf4f10
# ╟─0e34c082-2899-46e0-b755-644ce1393fe1
# ╟─09242936-990c-4448-a698-7113c347a830
# ╟─5d5db47f-28b4-47a6-828e-8c7ca51e4420
# ╟─a2078829-1c7e-430a-96e8-3177726dda88
# ╟─94ce62c7-34d2-4a88-a42d-3155e673d688
# ╟─8184bbc5-1641-40d0-86e7-8550aed8e4bf
# ╟─a2a93974-0f4d-43ca-9284-eb97ca998516
# ╟─9e1381e3-12ad-440e-8895-1d3a4dbae2f1
# ╟─7a24abdb-a706-4254-bf39-7c4440a7bb19
# ╟─2699840b-172a-43ab-9191-1404ff09965a
# ╟─052fb980-f438-49aa-ad09-fd45eb63cc42
# ╟─42481e5e-ad91-4079-8dd3-f295a8e8b390
# ╟─f7dc15ac-1763-4815-b8b1-1183eb018ba1
# ╟─3e779514-c5e2-48a4-970c-0bf3ac9d75bb
# ╟─af1d20f0-1b7d-4137-bfa7-ec010c18e648
# ╟─dbed3e23-83e3-424b-9a9d-d1da06cf8a6d
# ╟─650d22a2-49f8-4c97-931c-877e00b4a9b0
# ╟─33c13b61-ae9c-42fa-b553-7a40bb394b15
# ╟─3cef08cc-50f8-4662-82c9-7016fca91bb6
# ╟─055e980e-942a-4f02-9806-6060fe72ff52
# ╟─737f45ef-4d9e-4381-a6df-96886733ddd2
# ╟─71e0133d-e4db-41af-991a-8c7c8b577f3c
# ╟─c9c4b2f3-7256-4462-a260-38c6a5783e9f
# ╟─3ac4c6f0-a147-4558-af4f-bb95fa4b6eb3
# ╟─1df82d1c-b99d-4fc3-91d6-5457562db644
# ╟─9c141b09-02fa-44c7-97e6-2c237b03863e
# ╟─ada659cd-9686-4c9a-910d-7dafc9a26dcd
# ╟─3d48cc60-8a3d-4adf-9bcc-ff594f82b867
# ╟─84bc02a1-6df7-4462-b023-0a736dffc558
# ╟─88cbf89d-5961-4734-abe4-cc2143ccd21a
# ╟─1a8891f8-c631-4399-ae2e-1c1402c16944
# ╟─f0c50470-fbc1-46f2-9c61-11c57840d17f
# ╟─e5b9685e-2f6d-429d-a9e1-322952cc86d6
# ╟─d85d9910-c3be-4b47-8dce-16ed63e2b1ad
# ╟─89f679f4-eacc-4a8d-962e-d182927b0751
# ╟─2d3f36ba-c528-4a96-b043-445c5b5496cd
# ╟─64dd492b-6081-4823-9c23-fd437e5b9e8a
# ╟─c6e2b840-812f-46f3-a893-4722288fd97b
# ╟─a0d04824-dbe9-48e0-8645-dfc04c34d402
# ╟─3b1b4d48-43f5-4148-80dd-e5ae70ac3a7c
# ╟─f0aaab55-ed47-4349-9a17-885318c7291d
# ╟─33169b69-9f15-4257-b70d-14fbaf2ca25c
# ╟─a4f9c476-3037-435d-b32f-a4e8dfba628d
# ╟─927e5d42-df49-4638-a3a6-907886eb79fe
# ╟─f6a5d1fd-2f2c-43ec-94d5-ff781ed5064e
# ╟─df34ca45-c908-4149-ae08-614931b9bc48
# ╟─dd288a98-4a26-4e50-a36d-edf4ff3b7bb6
# ╟─2e82b832-0217-4a7b-906f-58a10e75eceb
# ╟─ba8b569b-cdf3-455d-b756-febd2065e4b3
# ╟─09d8bd33-957c-49a2-85e1-07075ec6e160
# ╟─b0150c24-7947-4766-be8b-5d51b7d79d89
# ╟─6599406d-679c-40b6-beac-02e16186b48f
# ╟─15b0e762-2b20-4687-aedc-d07ea6ab7638
# ╟─2e4391fc-8d94-4b02-915b-a2499b7196b4
# ╟─552421aa-c8a9-43c7-b43d-643d3bf22d85
# ╟─0ab19767-e8ee-4886-add4-4be7ee6449e2
# ╟─006a8095-09cb-4090-8225-94a33eae3b3d
# ╟─0fab3a87-ea04-41f9-9ed6-2c690d8179b7
# ╟─1b42f143-abe1-462c-9aa8-402802f8897a
# ╟─b9063748-0cc2-4639-b028-514e381685ff
# ╟─15f648a2-2217-47bf-b1dc-3e3529a7f07a
# ╟─39a070d8-fb75-46b7-8029-9a38490a6f16
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
