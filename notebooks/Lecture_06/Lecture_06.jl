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

# ╔═╡ 8a0644d5-74df-437f-b6ca-7a1625d09274
#Set-up packages
begin
	
	using DataFrames, Chain, HTTP, CSV, Dates, Plots, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, XLSX
	
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

# ╔═╡ f39dbca2-abd5-4e39-90da-ea74c7c08f0d
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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Term Structure of Interest Rates
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
<input type="checkbox" value="">Understand what the term structure of interest rates means.<br><br>
<input type="checkbox" value="">Know how to use the term structure of interest rates to price bonds.<br><br>
<input type="checkbox" value="">Understand how to bootstrap the yield curve.<br><br>
<input type="checkbox" value="">Know how to use discount factors to price bonds.<br><br>
<input type="checkbox" value="">Understand how to price a bond by replication.<br><br>
    </fieldset>      
	"""
end

# ╔═╡ d8a7f6e1-1167-40b4-8a6c-08d7c1b244c3
TableOfContents(aside=true, depth=1)

# ╔═╡ c7fe9523-b566-4d15-9396-768842d926d4
md"""
# Valuing Treasury Notes/Bonds
- Recall that to calculate the price $P$ of a Treasury note/bond with $T$ years to maturity, we need to calculate the present values (PV) of 
  - all coupon cash flows
  - and the principal cash flow at maturity

$$P = \textrm{PV(Coupon cash flows)} + \textrm{PV(Par value)}$$


"""

# ╔═╡ c9a7cfe0-5761-40bb-8359-30af8f780e53
md"""
##
"""

# ╔═╡ dd6befe9-d02d-4192-967c-7228430dbaed
md"""
- Specifically, given a discount rate $r$, and assuming that the bond pays semi-annual coupon cash flows (face value of 100), we calculate the bond price as follows:

$$P = \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 1.5}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 2.0}} + \ldots + \frac{100+C}{\left(1+\frac{r}{2}\right)^{2\times T}}$$

- We assumed that there is just one interest rate $r$ that we can use to discount all future cash flows.
- In reality, there are different interest rates $r$, for instance for different time horizons (e.g. 1-year vs. 5-year interest rates) and credit risk (e.g. Treasury securities vs. corporate bonds).


"""

# ╔═╡ 77883fdf-56b2-4759-90f9-b4618a44bbbd
md"""
##
"""

# ╔═╡ 9a483ab3-2b7e-45bf-8701-0a967a17b6ad
md"""
First, we are going to focus on the time dimension (and consider credit risk later). 
  - The idea is that because the coupon cash flows happen at different times in the future, it is not appropriate to use the same interest rate to discount all cash flows.
  - Each cash flow should be discounted at a unique rate appropriate for the time period in which the cash flow will be received.
- This means that for each time-$t$ cash flow in the future, there is a corresponding interest rate $r$.
- We will write the interest rate for time $t$ as $r(t)$ or simply as $r_t$.
- When we plot the relation between time on the horizontal axis and the corresponding interest rate on the vertical axis, this is referred to as the **Term Structure of Interest Rates**.
"""

# ╔═╡ d3a5c6e1-ea2c-4161-b0b6-04ca808653b1
md"""
##
"""

# ╔═╡ 6fb636a0-8115-42d4-980f-4885d55aff7b
md"""
- Thus, given interest rates $r(t)$, and assuming that the bond pays semi-annual coupon cash flows (face value of 100), we calculate the bond price as follows:

$$P = \frac{C}{\left(1+\frac{r_{0.5}}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{r_{1.0}}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{r_{1.5}}{2}\right)^{2\times 1.5}} + \frac{C}{\left(1+\frac{r_{2.0}}{2}\right)^{2\times 2.0}} + \ldots + \frac{100+C}{\left(1+\frac{r_{T}}{2}\right)^{2\times T}}$$
"""

# ╔═╡ 8ba33d66-2b7d-4657-b956-4d229b8e0981
md"""
- We refer to the interest rate $r(t)$ as **zero-coupon yields** (sometimes also referred to as **spot rates**).
- Why?
"""

# ╔═╡ 006cac44-88ae-42ef-88f0-c324f6dc76cf
md"""
##
"""

# ╔═╡ 2cf7a3a7-cc86-41a1-b0d8-076132c0f77d
md"""
- Recall that the price of a zero-coupon bond with $T$ years to maturity and face value of C and semi-annually-compounded yield $y_T$ is
$$P_T = \frac{C}{(1+\frac{y_T}{2})^{2T}}$$
- For example, the price of a 1-year zero-coupon bond is
$$P_1 = \frac{C}{(1+\frac{y_1}{2})^{2\times 1.0}}$$
- Let's compare this to the second term in the equation for $P$ (on the previous slide).
"""

# ╔═╡ 4596cd95-35bc-4786-86cd-215665121944
TwoColumn(
	md"""
	$$\frac{C}{\left(1+\frac{r_{1.0}}{2}\right)^{2\times 1.0}}$$
	""",
	md"""
	$$\frac{C}{(1+\frac{y_1}{2})^{2\times 1.0}}$$
	""")

# ╔═╡ cc275ce9-6548-48fc-a8ab-723937c4bb20
md"""
##
"""

# ╔═╡ 17eee939-014c-414b-80c2-703717d3098b
md"""
- Thus, we see that the correct discount rate that we need to use to calculate the present value of the 1-year coupon cash flow $r_1$ is equal to the yield of a one-year zero-coupon bond $y_1$.

$$r_1 = y_1$$

- This is also true for all $t$

$$r_t = y_t$$

- This means that in order find values for $r(t)$, we need to use market data on zero-coupon yields.
- When we collect market data of Treasury zero-coupon yields $y_t$ and make a graph with time $t$ on the horizontal axis and the corresponding yield on the vertical axis, we call this the a "Term Structure of Interest Rates" or "Zero-Coupon Yield Curve."
"""

# ╔═╡ d6c5298a-cccf-4755-a03d-966ac514fd28
md"""
# Term Structure of Interest Rates
"""

# ╔═╡ 477c6ad9-47dd-4aaa-ae17-9a8317a79ba0
md"""
- Let's look at the term structure of zero-coupon interest rates of Treasury securities.
- The Federal Reserve provides zero-coupon yield curves on its [webpage](https://www.federalreserve.gov/econres/feds/the-us-treasury-yield-curve-1961-to-the-present.htm).

"""

# ╔═╡ 85033a37-df2b-4fe6-a111-a420b90f256f
begin
	
	GSW = CSV.File(raw"./GSW/feds200628.csv"; header=10, skipto=11,missingstring="NA")|> DataFrame
	rename!(GSW,"SVENY01"=>"ZC_1","SVENY02"=>"ZC_2","SVENY03"=>"ZC_3","SVENY04"=>"ZC_4","SVENY05"=>"ZC_5","SVENY06"=>"ZC_6","SVENY07"=>"ZC_7","SVENY08"=>"ZC_8","SVENY09"=>"ZC_9","SVENY10"=>"ZC_10","SVENY11"=>"ZC_11","SVENY12"=>"ZC_12","SVENY13"=>"ZC_13","SVENY14"=>"ZC_14","SVENY15"=>"ZC_15","SVENY16"=>"ZC_16","SVENY17"=>"ZC_17","SVENY18"=>"ZC_18","SVENY19"=>"ZC_19","SVENY20"=>"ZC_20","SVENY21"=>"ZC_21","SVENY22"=>"ZC_22","SVENY23"=>"ZC_23","SVENY24"=>"ZC_24","SVENY25"=>"ZC_25","SVENY26"=>"ZC_26","SVENY27"=>"ZC_27","SVENY28"=>"ZC_28","SVENY29"=>"ZC_29","SVENY30"=>"ZC_30")
select!(GSW,"Date","ZC_1","ZC_2","ZC_3","ZC_4","ZC_5","ZC_6","ZC_7","ZC_8","ZC_9","ZC_10","ZC_11","ZC_12","ZC_13","ZC_14","ZC_15","ZC_16","ZC_17","ZC_18","ZC_19","ZC_20","ZC_21","ZC_22","ZC_23","ZC_24","ZC_25","ZC_26","ZC_27","ZC_28","ZC_29","ZC_30")
transform!(GSW, :Date => (x->Dates.year.(x)) => :Year, :Date => (x->Dates.month.(x)) => :Month, :Date => (x->Dates.day.(x)) => :Day)

GSW_m = @chain GSW begin
	groupby([:Year,:Month])
	combine(names(GSW,r"^ZC") .=> last, renamecols=false)
end
transform!(GSW_m,[:Year,:Month] => ByRow((y,m)->Dates.lastdayofmonth(Date(y,m,15)) ) => :Date)
select!(GSW_m,:Date,:Year,:Month,:)
filter!(:Year => (x->x>=2000),GSW_m)

end

# ╔═╡ e87659c1-ea1e-4485-b8da-fec178615a4a
md"""
##
"""

# ╔═╡ f37a7c80-872d-4e08-9658-9b9a37a92ee5
begin
	md"""
	- Date: $(@bind dateSelect_gsw Select(["31-Oct-2021","31-Mar-2020","30-Jun-2019","31-Jan-2012","31-Jan-2001"]))
	"""
end

# ╔═╡ ff03f612-4eef-4128-968f-26965106e558
md"""
##
"""

# ╔═╡ 64ac393d-fb3a-49fb-af85-333d518aecd9
begin
	md"""
	- Date: $(@bind gswZCSelect Select(["ZC_1"=>"1 Year","ZC_2"=>"2 Year","ZC_3"=>"3 Year","ZC_5"=>"5 Year","ZC_7"=>"7 Year","ZC_10"=>"10 Year","ZC_15"=>"15 Year","ZC_20"=>"20 Year","ZC_30"=>"30 Year"]))
	"""
end

# ╔═╡ 6c9e698c-893f-40ab-9569-b9094d2d8c28
begin
	T_Oct2021 = 2.5
	dt_Oct2021 = collect(0.5:0.5:T_Oct2021)
	F_Oct2021 = 100
	c_Oct2021 = 0.02
	r_Oct2021 = [0.09, 0.18, 0.33, 0.49, 0.63]
	C_Oct2021 = (c_Oct2021)/2*F_Oct2021 .* ones(length(r_Oct2021))
	C_Oct2021[end] += 100 
	DT_Oct2021 = 1 ./ (1 .+ r_Oct2021./200).^(dt_Oct2021)
	P_Oct2021 = sum(C_Oct2021./(1 .+ r_Oct2021./200).^(dt_Oct2021))
	display("")
end

# ╔═╡ 8bfbf282-d238-413b-878c-fca02b19c07b
md"""
## Example
"""

# ╔═╡ 3c7ab872-0c29-4b36-be54-354e050a7442
md"""
- Using the zero-coupon yield curve on October 31, 2021, let's now price a 2.5-year Treasury note. Suppose the Treasury note has a coupon rate of 2% (paid-semiannually) and face value of \$100.
- On 31 October, 2021, the zero-coupon yield curve out to five years is

 $t$ [years] | $r_t$ [%]
 :---|:----------
 0.5	| 0.09
 1.0	| 0.18
 1.5	| 0.33
 2.0	| 0.49
 2.5	| 0.63
 3.0	| 0.78
 3.5	| 0.90
 4.0	| 1.01
 4.5	| 1.10
 5.0	| 1.19
"""

# ╔═╡ 0f5fde6d-3498-46e9-a967-6e77ee8e4b7c
md"""
##
"""

# ╔═╡ 49d10018-14dc-4bcd-8def-0b9a61bfc2b4
md"""
- The semi-annual coupon cash flows are $C=\frac{2\%}{2}\times 100 = 1$
- To price the Treasury note, we discount all coupon cash flows and the principal cash flow at maturity by the corresponding discount rate $r(t)$.

$$P = \frac{C}{\left(1+\frac{r_{0.5}}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{r_{1.0}}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{r_{1.5}}{2}\right)^{2\times 1.5}} + \frac{C}{\left(1+\frac{r_{2.0}}{2}\right)^{2\times 2.0}} + \frac{100+C}{\left(1+\frac{r_{2.5}}{2}\right)^{2\times 2.5}}$$

"""

# ╔═╡ 19f40e49-30de-436e-9629-5a37fe531a82
md"""
##
"""

# ╔═╡ 06cc5f7f-2645-4a8a-a3b4-f001a1af67ab
Markdown.parse("
- Plugging in the values for ``r_t``

``\$ P = \\frac{$(C_Oct2021[1])}{\\left(1+\\frac{$(r_Oct2021[1])\\%}{2}\\right)^{2\\times 0.5}} + \\frac{$(C_Oct2021[2])}{\\left(1+\\frac{$(r_Oct2021[2])\\%}{2}\\right)^{2\\times 1.0}} + \\frac{$(C_Oct2021[3])}{\\left(1+\\frac{$(r_Oct2021[3])\\%}{2}\\right)^{2\\times 1.5}} + \\frac{$(C_Oct2021[4])}{\\left(1+\\frac{$(r_Oct2021[4])\\%}{2}\\right)^{2\\times 2.0}} + \\frac{$(F_Oct2021)+$(C_Oct2021[5])}{\\left(1+\\frac{$(r_Oct2021[5])\\%}{2}\\right)^{2\\times 2.5}} \$``

- The result is

``\$ P= \$ $(roundmult(P_Oct2021,1e-6))\$``
")

# ╔═╡ 5c5473e7-1fe3-4616-9161-667c9c7fab0d
md"""
##
"""

# ╔═╡ 4d60c557-ffdb-43c4-9951-53637c94a627
md"""
> **Concept Question**
> When we calculate the price of a bond, we calculate the
> 1. Full price.
> 2. Flat price.
> 3. Accrued interest.
"""

# ╔═╡ 5875b324-bc3a-446b-b565-18167efca3db
md"""
!!! hint
    We calculate the **Full Price**. The price we pay (we pay the full price, not the flat price) must be what the future cash flows of the bond are worth today. What the future cash flows of the bond are worth today is, of course, the present value of the bonds cash flows.
"""

# ╔═╡ 174e05eb-4af5-4bb1-a7ed-2a9840bd23f5
md"""
##
"""

# ╔═╡ 7388c008-c7e0-4743-94ab-bf3c53fdfb25
md"""
>**Practice Problem**
> Calculate the price of a coupon bond with the following terms: $1000 in face value, 5% coupon rate (paid semi-annually), 3 years to maturity.
>
> Time $t$ | Yield [%]
> :--------|:------------
> 0.5      | 0.06
> 1        | 0.120018
> 1.5      | 0.195093
> 2        | 0.270249
> 2.5      | 0.335465
> 3        | 0.400790

"""

# ╔═╡ 9e6bf80d-0c7e-4c98-9f20-4990c51208fa
Foldable("[Click to open solution]", 
md"
First, the coupon cash flow is $C=\frac{5\%}{2}\times 1000=25$

$$P = \frac{25}{(1+\frac{r_{0.5}}{2})^{2\times 0.5}} + \frac{25}{(1+\frac{r_{1.0}}{2})^{2\times 1.0}} + \frac{25}{(1+\frac{r_{1.5}}{2})^{2\times 1.5}} + \frac{25}{(1+\frac{r_{2.0}}{2})^{2\times 2.0}} + \frac{25}{(1+\frac{r_{2.5}}{2})^{2\times 2.5}} + \frac{1000 + 25}{(1+\frac{r_{3.0}}{2})^{2\times 3}}$$

$$P = \frac{25}{(1+\frac{0.0006}{2})^{2\times 0.5}} + \frac{25}{(1+\frac{0.00120018}{2})^{2\times 1.0}} + \frac{25}{(1+\frac{0.00195093}{2})^{2\times 1.5}} + \frac{25}{(1+\frac{0.00270249}{2})^{2\times 2.0}} + \frac{25}{(1+\frac{0.00335465}{2})^{2\times 2.5}} + \frac{1000 + 25}{(1+\frac{0.00400790}{2})^{2\times 3}} = 1137.31$$

")

# ╔═╡ de1c4d1a-4236-4a33-bf54-27e9e4f5fbcb
md"""
# Discount Factors
"""

# ╔═╡ b769331f-9209-48e3-87bb-a9a39cb20732
md"""
- For long-term bonds (time to maturity $T$ > 10 years), it becomes tedious to calculate the individual terms 

$$\frac{C}{\left(1+\frac{r_{T}}{2}\right)^{2\times T}}$$

- We can use a short-cut using so-called **Discount Factors**.
- Then, we can write these terms simply as

$$C\times D(T)$$

"""

# ╔═╡ b1a825a9-2c6c-4091-85c2-838962ee6299
md"""
##
"""

# ╔═╡ 6bee3304-fc31-4a69-aca1-511ed217430c
md"""
- Specifically, the bond pricing equation becomes


$$P = C\times D(0.5) + C\times D(1.0) + C\times D(1.5) + \ldots  + (C+100)\times
D(T)$$
"""

# ╔═╡ 5f9309e5-3421-4bca-b40a-4c1dff7c0fa5
md"""
##
"""

# ╔═╡ 20ebcc68-5107-4ec2-a5b1-5461edbebad5
md"""
- How do we get the discount factors $D(t)$?
- Compare the previous equation to the pricing equation we started with

$$P = \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 0.5}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 1.0}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 1.5}} + \frac{C}{\left(1+\frac{r}{2}\right)^{2\times 2.0}} + \ldots + \frac{100+C}{\left(1+\frac{r}{2}\right)^{2\times T}}$$
"""

# ╔═╡ 973ae4d4-b55f-4187-8b38-613c5b85acd5
md"""
- By comparing the terms, we get that

$$D(t) = \frac{1}{\left( 1+\frac{r_t}{2}\right)^{2\times t}}$$
"""

# ╔═╡ d9ef09eb-2f72-41dc-ad7b-14b7ba449224
md"""
##
"""

# ╔═╡ 288266f0-d22b-4ac9-ac0c-59081c359dfd
md"""
- Intuitively, what are discount factors?
- Let's look at the present value of \$1 to be received in 1-year (assuming semi-annual compounding) when the discount rate is $r_1$.

$$PV = \frac{1}{(1+\frac{r_1}{2})^{2\times 1}}$$

- Let's compare this to the one-year discount factor $D(1)$.

$$D(1) = \frac{1}{(1+\frac{r_1}{2})^{2\times 1}}$$

- Since the right-hand sides are equal,  we note that the discount factor $D(T)$ is the present value of \$1 to be received at time $T$.
  - For instance, $D(3)$ is the value today of \$1 paid in three years.
"""

# ╔═╡ f3ddfc93-4f07-499e-9112-daff0b8dea71
md"""
##
"""

# ╔═╡ e64d924e-1187-4c1d-b9fc-d100e0323ab9
md"""
- What are the properties of discount factors $D(T)$?
1. D(T) will usually be less than 1, since the present value of \$1 to be received in the future will in general be less than \$1 today.
2. D(T) becomes smaller as $T$ increases because the value today of \$1 to received goes down the further in the future it is received.
3. Under continuous compounding, when the discount rate is $r_T$, the discount factor is
$$D(T)=\exp(-r_T \times T)$$
"""

# ╔═╡ 09f38c05-9507-41df-b3da-5b720563e5bb
md"""
## Example
"""

# ╔═╡ 8bbd7dcd-ba0e-4688-96a2-63a309e5c5b3
begin
md"""
- Discount rate $r_T$ [% p.a.]: $(@bind r_DT Slider(0:0.25:10, default=2, show_value=true))
"""
end

# ╔═╡ 1153343a-f61f-4ddb-ae11-41164062115c
begin
	T_DT = collect(0:0.01:100)
	D_DT = exp.(-r_DT/100 .* T_DT)
	plot(T_DT,D_DT, 
	    	ylim=(0, 1.0), xlim=(0,T_DT[end]),
	    	ylabel="D(T)", xlabel="Years",fontfamily="Times New Roman",
	    	legend = :none, title="Discount Factors D(T)")	
end


# ╔═╡ 30bd80b0-213c-4358-a8dc-f7d2299fd4c3
md"""
## Example
"""

# ╔═╡ cd00e881-9e27-44ac-8334-d64255bbc3be
Markdown.parse("
- To illustrate, let's consider the previous example, where we calculated the price of a 2.5-year Treasury note with coupon rate of 2% (paid-semiannually).
- Suppose now that instead of zero-coupon yields, we have discount factors.


 ``t`` [years] | ``D(t)`` 
 :---|:----------
 0.5	| $(roundmult(DT_Oct2021[1],1e-4))
 1.0	| $(roundmult(DT_Oct2021[2],1e-4))
 1.5	| $(roundmult(DT_Oct2021[3],1e-4))
 2.0	| $(roundmult(DT_Oct2021[4],1e-4))
 2.5	| $(roundmult(DT_Oct2021[5],1e-4))
")

# ╔═╡ 1aad85e6-1a7d-41b4-9030-135d372dff58
md"""
##
"""

# ╔═╡ c428cca3-52c1-4e98-86b0-053518a81c46
Markdown.parse("
- Then, we calculate the bond price as follows.

``\$P = C\\times D(0.5) + C\\times D(1.0) + C\\times D(1.5) + C\\times D(2.0) + (C+100)\\times D(2.5)\$``

``\$\\downarrow\$``

``\$P = $(C_Oct2021[1])\\times $(roundmult(DT_Oct2021[1],1e-4)) + $(C_Oct2021[2])\\times $(roundmult(DT_Oct2021[2],1e-4)) + $(C_Oct2021[3])\\times $(roundmult(DT_Oct2021[3],1e-4)) + $(C_Oct2021[4])\\times $(roundmult(DT_Oct2021[4],1e-4)) + $(C_Oct2021[5])\\times $(roundmult(DT_Oct2021[5],1e-4))\$``

``\$\\downarrow\$``

``\$P =\$ $(roundmult(P_Oct2021,1e-6))\$``

")

# ╔═╡ 3a0b7467-e06d-45a6-86fa-c99e198137a6
md"""
# Par Yields
"""

# ╔═╡ 80be071d-89b4-460f-b3ca-51e1c5b7ac1b
md"""
- In the case of Treasury securities, we were given a zero-coupon yield curve.
- However, for corporate bonds, for instance, we typically do not observe zero-coupon yields directly.
- Instead, we can observe the **yields-to-maturity** of coupon bonds.
- In general, these are **not** zero-coupon yields that we can use to discount cash flows.
- Thus, we need a technique to get **zero-coupon yields** from yields of coupon bonds.
- This technique is referred to as **Boot Strapping**.
- Before we discuss boot strapping, we need to talk about **par yields**, because the yield curves we observe in the market are often **par yield curves.**
"""

# ╔═╡ 2876254b-3ad9-488e-9673-acceb7298de3
md"""
## Example: Corporate Bond Par Yield Curve
"""

# ╔═╡ 42397cc5-5188-4208-8cf2-8e7b90d2b05b
LocalResource("BloombergCorpA_ParYldCurve.png",:width => 1200)

# ╔═╡ f07435a0-cc62-47ca-bdc2-55e2120220a3
md"""
##
"""

# ╔═╡ f0b6fb53-274d-48d5-902d-fca896e89813
md"""
- What are **par yields?**
- The **Par Yield** is the yield to maturity of bonds that trade at **par** value.
  - To **trade** at par just means that the price is equal to par value, e.g.. the bond price is P=\$100 if the bond has face value of \$100.
- The **par yield curve** plots yield to maturity against term to maturity for current bonds trading at par.
"""

# ╔═╡ a94f0e2a-f0d4-41b5-bb86-b7107be07c3b
md"""
# Treasury Constant Maturity Yield Curve
"""

# ╔═╡ 241597f9-977e-4cb7-be70-256f52b97fdf
md"""
- Let's start by looking at one example of a **par yield curve** -- the so-called **Treasury Constant Maturity (CMT)** yield curve.
- The Federal Reserve provides daily term structures on its [webpage](https://www.treasury.gov/resource-center/data-chart-center/interest-rates/Pages/TextView.aspx?data=yield).
  - This specific term structure is referred as the "Constant Maturity Treasury" (CMT) yield curve.
"""

# ╔═╡ ad984cbe-64ca-4632-974c-ff071af4860d
md"""
##
"""

# ╔═╡ fb3983ca-a035-456c-8287-772924e4222e
md"""
- Treasury Constant Maturity Curve on November 1, 2021.
Tenor     | Time t     | $r$ [%]
:-------- | :----------| :-------------------------
1 Month   |	1/12=0.08  | 0.05
2 Months  |	2/12=0.17  | 0.09
3 Months  |	3/12=0.25  | 0.05
6 Months  |	6/12=0.50  | 0.06
1 Year    |	1.00	   | 0.15
2 Years   |	2.00	   | 0.50
3 Years   |	3.00	   | 0.79
5 Years   |	5.00	   | 1.20
7 Years   |	7.00	   | 1.46
10 Years  |	10.00	   | 1.58
20 Years  |	20.00	   | 2.01
30 Years  |	30.00	   | 1.98
"""

# ╔═╡ 2c89a8bd-ece5-4843-a1e5-422a8f71ba6b
md"""
##
"""

# ╔═╡ aa1f83b6-a767-481f-b2c1-fe238f40d969
begin
	md"""
	- Date: $(@bind dateSelect Select(["1-Nov-2021","4-Mar-2020","3-Jun-2019","3-Jan-2012","3-Jan-1995"]))
	"""
end

# ╔═╡ aca4ed6c-2124-4f0f-bc53-8c763e8e2daa
begin
	dt_gsw = collect(1:1:30)
	minX_gsw = 0.0
	maxX_gsw = 31.0
	minY_gsw = 0.0
	maxY_gsw = 5.0
	if dateSelect_gsw=="31-Oct-2021"
			r_gsw = collect(filter(:Date=> (x->x==Date(2021,10,31)),GSW_m)[1,4:end])
	elseif dateSelect_gsw=="31-Mar-2020"
			r_gsw = collect(filter(:Date=> (x->x==Date(2020,3,31)),GSW_m)[1,4:end])
	elseif dateSelect_gsw=="30-Jun-2019"
			r_gsw = collect(filter(:Date=> (x->x==Date(2019,6,30)),GSW_m)[1,4:end])
	elseif dateSelect_gsw=="31-Jan-2012"
			r_gsw = collect(filter(:Date=> (x->x==Date(2012,1,31)),GSW_m)[1,4:end])
	elseif dateSelect_gsw=="31-Jan-2001"
			maxY_gsw = 10.0
			r_gsw = collect(filter(:Date=> (x->x==Date(2001,1,31)),GSW_m)[1,4:end])
		end
		
		plot(dt_gsw, r_gsw, xlim=(minX_gsw,maxX_gsw), ylim=(minY_gsw, maxY_gsw),
			fontfamily="Times New Roman",
			xticks = [0,1,2,3,5,7,10,20,30], marker=:dot, markersize=2,
			xlabel = "Years", ylabel="Percent",label=dateSelect,
			legend = :topleft, title="Treasury Zero-Coupon Yield Curve")
		annotate!(dt_gsw[1:4:end], r_gsw[1:4:end].+0.2, text.(string.(roundmult.(r_gsw[1:4:end],1e-2)).*"%", :red, :right,8))
end

# ╔═╡ 6cee6d3f-38bb-434f-81d4-c3c8a9cae530
let
	dt = [0.08, 0.17, 0.25, 0.50, 1.00, 2.00, 3.00, 5.00, 7.00, 10.00, 20.00, 30.00]
	minX = 0.0
	maxX = 31.0
	minY = 0.0
	maxY = 5.0
	if dateSelect=="1-Nov-2021"
		r = [0.05, 0.09, 0.05, 0.06, 0.15, 0.50, 0.79, 1.20, 1.46, 1.58, 2.01, 1.98]
	elseif dateSelect=="4-Mar-2020"
		r = [1.00, 0.87, 0.72, 0.68, 0.59, 0.67, 0.68, 0.75, 0.90, 1.02, 1.45, 1.67]
	elseif dateSelect=="3-Jun-2019"
		r = [2.36, 2.36, 2.35, 2.31, 2.11, 1.82, 1.79, 1.83, 1.95, 2.07, 2.34, 2.53]
	elseif dateSelect=="3-Jan-2012"
		r = [0.01, 0.015, 0.02, 0.06, 0.12, 0.27, 0.40, 0.89, 1.41, 1.97, 2.67, 2.98]
	elseif dateSelect=="3-Jan-1995"
		maxY = 10.0
		r = [missing, missing, 5.95, 6.66, 7.23, 7.73, 7.84, 7.88, 7.91, 7.88, 8.07, 7.93]
	end
	
	plot(dt, r, xlim=(minX,maxX), ylim=(minY, maxY),
		fontfamily="Times New Roman",
		xticks = [0,1,2,3,5,7,10,20,30], marker=:dot, markersize=2,
		xlabel = "Years", ylabel="Percent",label=dateSelect,
		legend = :topleft, title="Treasury CMT Term Structure")
	annotate!(dt[6:end], r[6:end].+0.2, text.(string.(roundmult.(r[6:end],1e-2)).*"%", :red, :right,8))
end


# ╔═╡ 82b26083-1b70-4e2a-8313-375d136331d0
md"""
##
"""

# ╔═╡ 056c331d-acc2-443f-b9a6-f76d46d740a8
begin
	md"""
	- Date: $(@bind cmtSelect Select(["CMT_1M"=>"1 Month","CMT_3M"=>"3 Month", "CMT_6M"=>"6 Month","CMT_1Y"=>"1 Year","CMT_2Y"=>"2 Year","CMT_3Y"=>"3 Year","CMT_5Y"=>"5 Year","CMT_7Y"=>"7 Year","CMT_10Y"=>"10 Year", "CMT_20Y"=>"20 Year","CMT_30Y"=>"30 Year"]))
	"""
end

# ╔═╡ e4ce5ede-b04a-40e8-b50b-4fd839148938
let
	plotData = select(GSW_m, "Date",gswZCSelect)
	sort!(plotData,:Date)
	rename!(plotData,"Date" => :x, gswZCSelect => :y)
	dropmissing!(plotData)
	minY = 0.0
	maxY = 7
	plot(plotData.x,plotData.y, 
	    	ylim=(minY, maxY),
	    	ylabel="Percent",label="$(cmtSelect)",
			fontfamily="Times New Roman",
	    	legend = :none, title="Treasury Zero-Coupon Yield Curve")	
end

# ╔═╡ d842908e-59a0-42c5-8e7a-7dce812d42b4
begin
	
file = raw"CMT.csv"
CMT = CSV.File(file;missingstring="-999",dateformat="yyyy-mm-dd") |> DataFrame
mapcols!( x-> replace(x, -999.0=>missing), CMT)
transform!(CMT,:Date => (x->year.(x)) => :Year)
transform!(CMT,:Date => (x->month.(x)) => :Month)
select!(CMT,:Date,:Year,:Month, r"^CMT")

CMT_m = @chain CMT begin
  	groupby([:Year,:Month])
  	combine([:CMT_1M, :CMT_3M, :CMT_6M, :CMT_1Y, :CMT_2Y, :CMT_3Y, :CMT_5Y, :CMT_7Y, 		 
		:CMT_10Y, :CMT_20Y, :CMT_30Y] .=> (x->last(x)), renamecols=false)
end

transform!(CMT_m,[:Year,:Month] => ByRow((y,m)->Dates.lastdayofmonth(Date(y,m,15)) ) => :Date)
select!(CMT_m,:Date,:Year,:Month,:)
plotData = select(CMT_m, "Date",cmtSelect)
sort!(plotData,:Date)
rename!(plotData,"Date" => :x, cmtSelect => :y)
dropmissing!(plotData)
minY = 0.0
maxY = 7
plot(plotData.x,plotData.y, 
    	ylim=(minY, maxY),
    	ylabel="Percent",label="$(cmtSelect)",
		fontfamily="Times New Roman",
    	legend = :none, title="Treasury CMT Yield Curve")	
end

# ╔═╡ 7c438487-5fd8-44fa-bc51-8cba228d950e
md"""
##
"""

# ╔═╡ 81366ff1-314b-492a-bb41-0e2b2106ecd1
md"""
- Treasury CMT rates at the St. Louis Fed: [CMT](https://fred.stlouisfed.org/categories/115)
"""

# ╔═╡ 9973cab2-eff7-4ebe-a223-abc258fb08f6
md"""
# Bond prices and Yields
"""

# ╔═╡ 81fa26da-ffe2-40e1-8dc2-ef466417d2a2
md"""
- Recall that the **par yield** is the *yield to maturity* of bonds that trade at **par** value, i.e. the bond price is equal to $100 (for bonds with 100 face value).
- To get a sense of how the bond price and the yield to maturity are related, let's consider a Treasury note with maturity in $T$ years, coupon rate of $c$ (paid semi-annually), principal value of \$100 and yield to maturity $y$.
"""

# ╔═╡ 91e59ee9-7736-4067-8eb2-4900b3930b29
md"""
##
"""

# ╔═╡ 8ab51844-183b-4a35-a95d-561342fdfbfa
@bind bttn_3 Button("Reset")

# ╔═╡ b5813779-1212-419c-aead-a25b4ff0a6af
begin
bttn_3
md"""
- Time to maturity $T$ [years]: $(@bind T_3 Slider(0:0.5:30, default=5, show_value=true))
- Coupon rate $c$ [% p.a.]: $(@bind c_3 Slider(0:0.5:10, default=4, show_value=true))
- Yield to maturity $y$ [% p.a.]: $(@bind yld_3 Slider(0:0.25:10, default=3, show_value=true))
"""
end

# ╔═╡ 130f1225-7bb8-41eb-a234-b33fd3c82e69
begin
	dt3 = collect(0.5:0.5:T_3)
	CF3 = (c_3/200*100).*ones(length(dt3))
	CF3[end] += 100
	PV3 = CF3./(1 .+ yld_3 ./ 200).^(2 .* dt3)
	PV3[end] = PV3[end]
	PV3total = sum(PV3)
	DT3 = 1 ./ (1 .+ yld_3 ./ 200).^(2 .* dt3)
	tmpStr3 = Vector{String}()
	for idx=1:length(CF3)
	 	push!(tmpStr3,"$(CF3[idx]) * 1/(1+$yld_3%/2)^(2*$(dt3[idx]))=$(roundmult(PV3[idx],1e-4))")
	end
	tmpStr32 = string(roundmult(PV3[1],1e-4))
	for idx=2:length(CF3)
		global tmpStr32 = tmpStr32 * " + " * string(roundmult(PV3[idx],1e-4))
	end
	tmpStr32 = tmpStr32 * " = " * string(roundmult(PV3total,1e-6))
	
	df3 = DataFrame(Time=dt3,DiscountFactor=DT3,CashFlow=CF3,PresentValue=PV3,Calculation=tmpStr3)
end

# ╔═╡ 0c3c21d0-070d-4b11-8570-a414610cd655
md"""
- Bond Price: \$ $(roundmult(PV3total,1e-4))
"""

# ╔═╡ 6176eda8-06e7-4ca3-bd4d-cf21e816ec89
md"""
# Bond Price-Yield Relation
"""

# ╔═╡ b46f0d36-287c-4dba-8d9f-f0946948ae41
md"""
- By varying the yield to maturity $y$ and the coupon rate $c$, we notice the following:
- When the yield is **equal** to the coupon rate, the price of the bond is *equal* to  its par value.
  - This is called a **par bond**, the the yield is called the **par yield**.
- If the yield is **greater** than the coupon rate, the price is *less* than par value.
  - This is called a **discount bond**, and the bond is *trading at a discount*.
- If the yield is **less** than the coupon rate, the price is *greater* than par, and 
  - This is called a **premium bond**, and the bond is trading at a *premium*.
"""

# ╔═╡ af83328e-abd4-4005-adab-dcfd659e7a6f
md"""
##
"""

# ╔═╡ d1f4d03a-7289-4a0e-8ba0-6263ea3b82f5
md"""
- Next, let's plot the yield to maturity on the horizontal axis and the bond price on the vertical axis.
- This is called the **price-yield relation**.
"""

# ╔═╡ 5c59b688-24e7-4242-a100-76196a867703
@bind bttn_4 Button("Reset")

# ╔═╡ 609a8d9c-9ca5-4d87-9c6e-f58f38183f80
begin
bttn_4
md"""
- Time to maturity $T$ [years]: $(@bind T_4 Slider(0:0.5:30, default=5, show_value=true))
- Coupon rate $c$ [% p.a.]: $(@bind c_4 Slider(0:0.5:10, default=4, show_value=true))
"""
end

# ╔═╡ 6e1e6d2b-37a7-494c-ac85-a982fedf5af7
begin
	dt4 = collect(0.5:0.5:T_4)
	CF4 = (c_4/200*100).*ones(length(dt4))
	CF4[end] += 100
	yld_4 = collect(0.1:0.001:10)
	PV4total = zeros(length(yld_4))
	for idx=1:length(yld_4)
		PV4 = CF4./(1 .+ yld_4[idx] ./ 200).^(2 .* dt4)
		PV4total[idx] = sum(PV4)
	end
	plot(yld_4, PV4total, xlim=(yld_4[1],yld_4[end]), ylim=(0, 150),
		fontfamily="Times New Roman",
		xlabel = "Yield [%]", ylabel="Bond Price per 100 Par Value",
		legend = :none, title="Price-Yield Relation")
end

# ╔═╡ 52161fc1-a6ea-4d84-a236-982ab8b89373
md"""
##
"""

# ╔═╡ 21bd8072-e942-4bfe-8c4e-3324f2e27c98
md"""
- We see that as the yield increases, the bond price decreases.
- This is referred to as **inverse** relation between prices and yields.
  - It just means that prices and yields move in opposite directions.
- We also see that the relation between prices and yields is not a straight line, but the relation has curvature. It is **convex**.
"""

# ╔═╡ c2ee0596-e2f8-4d9c-a72d-db38cce61dba
md"""
##
"""

# ╔═╡ 2b3dc41a-4343-4682-80bc-f2d8b2e7a66f
md"""
> **Example from the CFA Exam**
>
> Bond | Price    | Coupon Rate  | Time-to-Maturity
>:----|:---------|:-------------|:-----------------
>A    | 101.886  | 5%           | 2 years  
>B    | 100.000  | 6%           | 2 years  
>C    | 97.327   | 5%           | 3 years   
>
>Which bond offers the lowest yield to maturity?
>
>*Source: Petitt, Pinto, and Pirie (2015)*
"""

# ╔═╡ c46d8696-78aa-49f2-a28d-7c68ad583106
md"""
!!! hint
    - We know that Bond A has a yield < 5% because it is trading at a premium.
    - We know that Bond B has a yield of 6% as it is trading at par.
    - We know that Bond C has a yield > 5% as it is trading at a discount.
    - Thus, the answer is A.
"""

# ╔═╡ cfda03e7-87c2-4418-8203-a768696ce5d1
md"""
# Bootstrapping the zero-coupon yield curve
"""

# ╔═╡ e5d2463f-780f-40de-a47b-c0528e0ce2c3
md"""
- Now that we understand what **par yields** are and how prices and yields are related, let's now answer the question how we can calculate the **zero-coupon yield curve** from a **par yield curve**.
- To illustrate, let's consider the Treasury par yield curve on November 25, 2021 out to 5-years to maturity.
"""

# ╔═╡ 33a18a43-9bed-4377-8f0c-9ddc2d9e3044
md"""
##
"""

# ╔═╡ 4f4f686a-c1c4-4f2b-8758-0d5658a21599
LocalResource("./BloombergTreas_ParYldCurve_25Nov2021.png",:width => 1200)

# ╔═╡ b54c4120-cd0c-4d39-b16b-2428551f23ec
md"""
##
"""

# ╔═╡ 9c28bdfc-76ea-4125-9ca8-cc81007077e5
md"""

 $t$ [years] | $c_t$ [%]
 :---|:----------
 0.5	| 0.095 
 1.0	| 0.213
 1.5	| 0.437
 2.0	| 0.643
 2.5	| 0.806
 3.0	| 0.965
 3.5	| 1.063
 4.0	| 1.155
 4.5	| 1.248
 5.0	| 1.344

"""

# ╔═╡ 9023c41b-6481-44b9-93d4-431460dfc5b5
begin
	F5 = 100
	dt5 = collect(0.5:0.5:5)
	r5 = [0.095, 0.213, 0.437, 0.643, 0.806, 0.965, 1.063, 1.155, 1.248, 1.344]
	C5 = r5./200 .* F5
	D5 = zeros(length(dt5))
	D5[1] = F5/(F5+C5[1])
	for idx=1:length(dt5)
		D5[idx] = (F5-C5[idx] * sum(collect(D5[1:idx-1])))/(F5+C5[idx])
	end
	y5 = 2 .* ( (1 ./ D5).^(1 ./ (2 .* dt5)) .-1 )
	df5 = DataFrame(Time=dt5, C=C5, DT=D5, r_t=y5.*100)
	display("")
end

# ╔═╡ b6cb2bca-d1f1-42e2-9d5e-2517818f914d
md"""
- **Note:** The column with the par yield curve rates is labeled $c_t$. 
  - Recall that this is because the par yields are coupon rates of Treasury notes trading at par.
  - When a Treasury note is trading at par its yield is the same as its coupon rate.
"""

# ╔═╡ 257f1590-9a62-43f8-b9b9-a878fb674bb2
md"""
##
"""

# ╔═╡ 41f4bcb8-79b8-44ae-b1f4-9d77b41ea399
md"""
- To **boostrap** the zero-coupon yield curve form the par yield curve above, we proceed in steps.
  - First, we calculate the discount factor $D(0.5)$ for the 6-month (t=0.5) maturity. 
  - Next, we calculate the discount factor $D(1.0)$ for the 1-year (t=1) maturity. 
  - Then, we calculate the discount factor $D(1.5)$ for the 1.5-year (t=1) maturity. 
  - We continue this procedure until and including the 5-year maturity (in this example).
- In the last step, we convert all discount factors $D(t)$ to zero-coupon yields
  - We know

$$D(t)=\frac{1}{(1+\frac{r_t}{2})^{2\times t}}$$

thus

$$r_t=2\times \left( \left(\frac{1}{D(t)}\right)^{\frac{1}{2\times t}}-1\right)$$
"""

# ╔═╡ f9f13e8f-070a-4696-98a7-25235cd65f6a
md"""
##
"""

# ╔═╡ c0233306-7dfd-4a50-b870-411cd76998cb
Markdown.parse("
- **Step 1**: ``t=0.5``
  - The par yield is ``$(r5[1]) \\%``. This means a Treasury coupon bond with a coupon rate of ``c=$(r5[1])\\%``  has a price ``P=\\\$ 100``.
  - Since coupon cash flows are semi-annual, the six-month bond has one remaining cash flow in ``t=0.5`` years of principal ``F=100`` plus coupon ``C=\\frac{$(r5[1])\\%}{2}\\times $F5=$(C5[1])``. 
   - We are looking for the discount factor ``D(0.5)`` that sets the present value of the Treasury note's final cash flow of ``$(roundmult(r5[1]+F5,1e-4))`` equal to its price of ``100``.

``\$100\\stackrel{!}{=} D(0.5) \\times $(roundmult(r5[1]+F5,1e-4)) \\rightarrow D(0.5)= $(roundmult(D5[1],1e-6))\$`` 
")

# ╔═╡ 714641c3-8e0a-4bc5-8f13-2ff57b1ad6d6
md"""
##
"""

# ╔═╡ 7ed3b0c1-1557-4dd2-9065-e31e78dce2d3
Markdown.parse("
- **Step 2**: ``t=1.0``
  - The par yield is ``$(r5[2]) \\%``. This means a Treasury coupon bond with a coupon rate of ``c=$(r5[2])\\%``  has a price ``P=\\\$ 100``.
  - Since coupon cash flows are semi-annual, the one-year bond has two remaining cash flows in ``t=0.5`` years of ``C=$(C5[2])`` and one in ``t=1.0`` year of principal plus coupon ``F+C=$(roundmult(r5[2]+F5,1e-4))``. 

``\$100\\stackrel{!}{=} D(0.5) \\times $(C5[2]) + D(1.0) \\times $(roundmult(r5[2]+F5,1e-4)) \$`` 

  - We use ``D(0.5)=$(roundmult(D5[1],1e-6))`` from the first step.

``\$100\\stackrel{!}{=} $(roundmult(D5[1],1e-6)) \\times $(C5[2]) + D(1.0) \\times $(roundmult(r5[2]+F5,1e-4)) \$`` 

``\$\\rightarrow D(1.0)= $(roundmult(D5[2],1e-6))\$``
")

# ╔═╡ d6c0f8ff-06c6-493c-b9a6-6ebfa284382a
md"""
##
"""

# ╔═╡ 732a841f-2a4e-4487-b29e-65ad09273a4e
Markdown.parse("
- **Step 3**: ``t=1.5``
  - The par yield is ``$(r5[3]) \\%``. This means a Treasury coupon bond with a coupon rate of ``c=$(r5[3])\\%``  has a price ``P=\\\$ 100``.
  - Since coupon cash flows are semi-annual, the 1.5-year bond has three remaining cash flows. Two cash flows of ``C=$(C5[3])`` in ``t=0.5`` and ``t=1.0`` years and one in ``t=1.5`` year of principal plus coupon ``F+C=$(roundmult(r5[3]+F5,1e-4))``. 

``\$100\\stackrel{!}{=} D(0.5) \\times $(C5[3]) + D(1.0) \\times $(C5[3]) + D(1.5) \\times $(roundmult(r5[3]+F5,1e-4)) \$`` 

  - We use ``D(0.5)=$(roundmult(D5[1],1e-6))`` from the first step.
  - And we use ``D(1.0)=$(roundmult(D5[2],1e-6))`` from the second step.

``\$100\\stackrel{!}{=} $(roundmult(D5[1],1e-6)) \\times $(C5[3]) + $(roundmult(D5[2],1e-6)) \\times $(C5[3]) + D(1.5) \\times $(roundmult(r5[3]+F5,1e-4)) \$`` 

``\$\\rightarrow D(1.5)= $(roundmult(D5[3],1e-6))\$``
")

# ╔═╡ 9c063461-886a-4f20-8854-67a059a1c775
md"""
##
"""

# ╔═╡ da630ce0-4135-4e53-9544-1506d18226c5
Markdown.parse("
- We continue until ``t=5`` and in doing so, we get
")

# ╔═╡ 3e616a98-236a-4c72-a1ee-6bb3b296a479
  (select(df5,:Time,:DT))

# ╔═╡ 72e204df-a22d-4280-8af9-153cbf69af0d
md"""
##
"""

# ╔═╡ eea75cb5-4461-407e-8ac3-5a79c088ebf3
Markdown.parse("
- Finally, we just need to get the zero coupon yields using the equation
``\$r_t=2\\times \\left( \\left(\\frac{1}{D(t)}\\right)^{\\frac{1}{2\\times t}}-1\\right)\$``

- For instance, the ``t=0.5`` year zero-coupon yield is
``\$ r_{0.5} = 2\\times \\left( \\left(\\frac{1}{D(0.5)}\\right)^{\\frac{1}{2\\times 0.5}}-1\\right)\$``

``\$ r_{0.5} = 2\\times \\left( \\left(\\frac{1}{$(roundmult(D5[1],1e-6))}\\right)^{\\frac{1}{2\\times 0.5}}-1\\right) = $(roundmult(y5[1]*100,1e-6))\\%\$``

")

# ╔═╡ e1c1a6e9-0050-40be-9dfe-fe77f2444e17
md"""
##
"""

# ╔═╡ e555dbab-4f2a-4ca8-a29f-fe87541466ea
md"""
- Continuing with $t=1.0 \ldots 5.0$, we get $r_t$ for $t=0.5,\ldots,5$.
  - Note the value for $r_t$ shown in the table below are in percent.
"""

# ╔═╡ f3ac1b29-5549-4505-a33c-4a9fe3067b6b
(select(df5,:Time,:r_t))

# ╔═╡ 4a6e7a75-eed3-4796-b42d-dbec4e184aed
md"""
##
"""

# ╔═╡ 89fcb4d1-a469-47ad-9325-5a33fa53e4aa
md"""
>**Practice Problem**
> 
>Bootstrap the zero-coupon yield curve out to five years (in 6-month intervals).
>
>  T   | Maturity date   | Coupon rate  | Price  | Yield
>  :---|:----------------|:-------------|:-------|:--------
>  0.5 | 1/30/2020       | 0            | 98.81  | 0.024087
>  1   | 6/30/2020       | 0.025        | 100.53 | 0.019622
>  1.5 | 1/31/2021       | 0.02125      | 100.41 | 0.018466
>  2   | 6/30/2021       | 0.01125      | 98.69  | 0.017943
>  2.5 | 1/31/2022       | 0.01875      | 100.25 | 0.017723
>  3   | 6/30/2022       | 0.0175       | 99.97  | 0.017603
>  3.5 | 1/31/2023       | 0.02375      | 102.03 | 0.017742
>  4   | 6/30/2023       | 0.02625      | 103.22 | 0.017873
>  4.5 | 1/31/2024       | 0.025        | 103.03 | 0.017961
>  5   | 6/30/2024       | 0.02         | 100.84 | 0.018235
"""

# ╔═╡ e3cd1f54-d3e5-4722-bdd8-9cb445ee5634
md"""
##
"""

# ╔═╡ 3a556731-cbf6-4dbf-a7bf-02e1de8f0096
begin
	F6 = 100
	P6 = [98.81, 100.53, 100.41, 98.69, 100.25, 99.97, 102.03, 103.22, 103.03, 100.84]
	dt6 = collect(0.5:0.5:5)
	r6 = [0.0, 0.025, 0.02125, 0.01125, 0.01875, 0.0175, 0.02375, 0.02625, 0.025, 0.02].*100
	C6 = r6./200 .* F6
	D6 = zeros(length(dt6))
	D6[1] = P6[1]/(F6+C6[1])
	for idx=2:length(dt6)
		D6[idx] = (P6[idx]- (C6[idx] * sum(collect(D6[1:idx-1]))))/(F6+C6[idx])
	end
	y6 = 2 .* ( (1 ./ D6).^(1 ./ (2 .* dt6)) .-1 )
	df6 = DataFrame(Time=dt6, C=C6, DT=D6, r_t=y6.*100)
end

# ╔═╡ 1e6014b5-09d2-474c-9d21-154079c8aec2
md"""
## Solution
"""

# ╔═╡ 95c5cb60-39c1-439f-9451-cf1096715773
Foldable("[Click to open solution]", 
md"

- Start with the 0.5-year bond:
  - We actually know that the yield is 2.4087%. 
  - But let's do the calculation anyway.
  - Price = \$98.81
  - Coupon = \$1.25
$$98.81 = \frac{100}{(1+\frac{r_{0.5}}{2})^{2\times 0.5}} \rightarrow r_{0.5} == .024086631$$

- Next, use the 1-year bond:
  - Coupon rate = 2.5%, Price = \$100.53
  - Coupon = \$1.25 , 
$$100.53 = \frac{1.25}{(1+\frac{.024086631}{2})^{2\times 0.5}} + \frac{101.25}{(1+\frac{r_{1.0}}{2})^{2\times 1}} \rightarrow r_{1.0} = 0.019594107$$

- Next, use the 1.5-year bond:
  - Coupon rate= 2.125\%, Price=\$100.41
  - Coupon = \$1.0625 
$$100.41 = \frac{1.0625}{(1+\frac{0.024086631}{2})^{2\times 0.5}} + \frac{1.0625}{(1+\frac{0.019594107}{2})^{2\times 1.0}} + \frac{101.0625}{(1+\frac{r_{1.5}}{2})^{2\times 1.5}} \rightarrow r_{1.5} = 0.01843806$$

- Continuing until t=5 years

Maturity | Zero-coupon yield | Maturity | Zero-coupon yield
:--------|:------------------|:---------|:------------------
0.5      | 0.024087          | 3        | 0.017581045
1        | 0.019594108       | 3.5      | 0.017721797
1.5      | 0.01843806        | 4        | 0.017859173
2        | 0.017932055       | 4.5      | 0.017953593
2.5      | 0.01769831        | 5        | 0.018242097

")

# ╔═╡ d10007b6-1144-46bc-99f6-26dc458b69c6
md"""
# Pricing Notes/Bonds by Replication
"""

# ╔═╡ 629390e6-b383-4b5d-84db-513c1be494f9
md"""
- Replicate a 1-year bond, with a face value of $100 and a coupon rate of 5% using the following set of bonds.

T   | Maturity date   | Coupon rate  | Price  | Yield
:---|:----------------|:-------------|:-------|:--------
0.5 | 1/30/2020       | 0            | 98.81  | 0.024087
1   | 6/30/2020       | 0.025        | 100.53 | 0.019622
1.5 | 1/31/2021       | 0.02125      | 100.41 | 0.018466
2   | 6/30/2021       | 0.01125      | 98.69  | 0.017943
2.5 | 1/31/2022       | 0.01875      | 100.25 | 0.017723
3   | 6/30/2022       | 0.0175       | 99.97  | 0.017603
3.5 | 1/31/2023       | 0.02375      | 102.03 | 0.017742
4   | 6/30/2023       | 0.02625      | 103.22 | 0.017873
4.5 | 1/31/2024       | 0.025        | 103.03 | 0.017961
5   | 6/30/2024       | 0.02         | 100.84 | 0.018235

- *Assume that we can by fractions of one bond (e.g. we can buy a principal amount of \$50 of the six-month bond above for a price of 0.5 $\times$ \$98.81=\$49.405*.
"""

# ╔═╡ 685488f4-7218-4929-b41c-9d2cdf00fb00
md"""
##
"""

# ╔═╡ 0b023c4d-64c9-4ed1-8dca-cc2dce2f9302
md"""
Let's start by writing down the cash flows that we are trying to replicate

Position                   | Units   | t=0        | t=0.5     | t=1
:--------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 5% coupon rate  | 1       | ?          | 2.5       | 102.5

"""

# ╔═╡ 67f40f7c-ef46-4a25-8c4d-751d2fb99ac8
md"""
##
"""

# ╔═╡ c9369621-acda-4bb2-a36a-f40665dc8943
md"""
Let's set up a replicating portfolio

Position                   | Units   | t=0        | t=0.5     | t=1
:--------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 5% coupon rate  | 1       | $P_1$      | 2.5       | 102.5

Replicating Portfolio        | Units   | t=0        | t=0.5     | t=1
:----------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 2.5% coupon rate  |         |            |           | 
0.5-yr bond, 0% coupon rate  |         |            |           | 
"""

# ╔═╡ b4580191-b4ae-498c-a048-cd9e48fcde09
md"""
##
"""

# ╔═╡ 588aa3cc-5c7b-4212-a34f-caf49babbee3
md"""
Let's try 1 unit of the 1-year bond in the replicating portfolio

Position                   | Units   | t=0        | t=0.5     | t=1
:--------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 5% coupon rate  | 1       | $P_1$          | 2.5       | 102.5

Replicating Portfolio        | Units   | t=0        | t=0.5     | t=1
:----------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 2.5% coupon rate  | 1       | -100.53    |  1.25     | 101.25
0.5-yr bond, 0% coupon rate  |         |            |           | 
Total of Replicating Portfolio| | |
"""

# ╔═╡ ebe39eef-ee8e-4d06-9993-8ffb84a72f9f
md"""
##
"""

# ╔═╡ 23d731aa-699a-48be-a8d2-b8c558538c71
md"""
- Since, we are not matching the cash flows of 2.5 at t=0.5 and 102.5 at t=1, let's adjust the position in the 1-year 2.5% coupon bond.
- To match the 102.5, we more than one unit. Specifically, we need $\frac{102.5}{101.25}=1.012345679$ units.
- The coupon cash flow at t=0.5 is then $1.012345679 \textrm{ units} \times 1.25=1.2654$.
- To match the cash flow of 2.5, we use the 0.5-year zero coupon bond.
- We need to make up the difference of $2.5-1.2654=1.2346$.
- Thus, we buy a 6-month zero coupon bond with face value of 1.2346. This costs, $1.2346 \times \frac{98.81}{100}=1.2346\times 0.9881=1.22$
- Thus, we have the replicating portfolio.
"""

# ╔═╡ 5988bfe0-a62d-4574-b844-1a8a965b15d0
md"""
##
"""

# ╔═╡ f5fd87c9-b016-4428-8530-518d8998f377
md"""
Position                   | Units   | t=0        | t=0.5     | t=1
:--------------------------|:--------|:-----------|:----------|:-----------
1-yr bond, 5% coupon rate  | 1       | $P_1$          | 2.5       | 102.5

Replicating Portfolio        | Units    | t=0        | t=0.5     | t=1
:----------------------------|:---------|:-----------|:----------|:-----------
1-yr bond, 2.5% coupon rate  | 1.01235  | -100.53    |  1.2654   | 102.50
0.5-yr bond, 0% coupon rate  | 0.012346 | -1.22      |  1.2346   | 0 
Total of Replicating Portfolio|         | -102.99    |  2.5      | 102.50

- Thus, the price of the 1-year coupon with coupon rate of 2.5% must be equal to 102.99.
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
<input type="checkbox" value="" checked>Understand what the term structure of interest rates means.<br><br>
<input type="checkbox" value="" checked>Know how to use the term structure of interest rates to price bonds.<br><br>
<input type="checkbox" value="" checked>Understand how to bootstrap the yield curve.<br><br>
<input type="checkbox" value="" checked>Know how to use discount factors to price bonds.<br><br>
<input type="checkbox" value="" checked>Understand how to price a bond by replication.<br><br>
    </fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
# Reading
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 6
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
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
Chain = "~0.4.10"
DataFrames = "~1.2.2"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
Plots = "~1.23.6"
PlutoUI = "~0.7.20"
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

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[Chain]]
git-tree-sha1 = "339237319ef4712e6e5df7758d0bccddf5c237d9"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.10"

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
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

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
# ╟─41d7b190-2a14-11ec-2469-7977eac40f12
# ╟─8a0644d5-74df-437f-b6ca-7a1625d09274
# ╟─f39dbca2-abd5-4e39-90da-ea74c7c08f0d
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─d8a7f6e1-1167-40b4-8a6c-08d7c1b244c3
# ╟─c7fe9523-b566-4d15-9396-768842d926d4
# ╟─c9a7cfe0-5761-40bb-8359-30af8f780e53
# ╟─dd6befe9-d02d-4192-967c-7228430dbaed
# ╟─77883fdf-56b2-4759-90f9-b4618a44bbbd
# ╟─9a483ab3-2b7e-45bf-8701-0a967a17b6ad
# ╟─d3a5c6e1-ea2c-4161-b0b6-04ca808653b1
# ╟─6fb636a0-8115-42d4-980f-4885d55aff7b
# ╟─8ba33d66-2b7d-4657-b956-4d229b8e0981
# ╟─006cac44-88ae-42ef-88f0-c324f6dc76cf
# ╟─2cf7a3a7-cc86-41a1-b0d8-076132c0f77d
# ╟─4596cd95-35bc-4786-86cd-215665121944
# ╟─cc275ce9-6548-48fc-a8ab-723937c4bb20
# ╟─17eee939-014c-414b-80c2-703717d3098b
# ╟─d6c5298a-cccf-4755-a03d-966ac514fd28
# ╟─477c6ad9-47dd-4aaa-ae17-9a8317a79ba0
# ╟─85033a37-df2b-4fe6-a111-a420b90f256f
# ╟─e87659c1-ea1e-4485-b8da-fec178615a4a
# ╟─f37a7c80-872d-4e08-9658-9b9a37a92ee5
# ╟─aca4ed6c-2124-4f0f-bc53-8c763e8e2daa
# ╟─ff03f612-4eef-4128-968f-26965106e558
# ╟─64ac393d-fb3a-49fb-af85-333d518aecd9
# ╟─e4ce5ede-b04a-40e8-b50b-4fd839148938
# ╟─6c9e698c-893f-40ab-9569-b9094d2d8c28
# ╟─8bfbf282-d238-413b-878c-fca02b19c07b
# ╟─3c7ab872-0c29-4b36-be54-354e050a7442
# ╟─0f5fde6d-3498-46e9-a967-6e77ee8e4b7c
# ╟─49d10018-14dc-4bcd-8def-0b9a61bfc2b4
# ╟─19f40e49-30de-436e-9629-5a37fe531a82
# ╟─06cc5f7f-2645-4a8a-a3b4-f001a1af67ab
# ╟─5c5473e7-1fe3-4616-9161-667c9c7fab0d
# ╟─4d60c557-ffdb-43c4-9951-53637c94a627
# ╟─5875b324-bc3a-446b-b565-18167efca3db
# ╟─174e05eb-4af5-4bb1-a7ed-2a9840bd23f5
# ╟─7388c008-c7e0-4743-94ab-bf3c53fdfb25
# ╟─9e6bf80d-0c7e-4c98-9f20-4990c51208fa
# ╟─de1c4d1a-4236-4a33-bf54-27e9e4f5fbcb
# ╟─b769331f-9209-48e3-87bb-a9a39cb20732
# ╟─b1a825a9-2c6c-4091-85c2-838962ee6299
# ╟─6bee3304-fc31-4a69-aca1-511ed217430c
# ╟─5f9309e5-3421-4bca-b40a-4c1dff7c0fa5
# ╟─20ebcc68-5107-4ec2-a5b1-5461edbebad5
# ╟─973ae4d4-b55f-4187-8b38-613c5b85acd5
# ╟─d9ef09eb-2f72-41dc-ad7b-14b7ba449224
# ╟─288266f0-d22b-4ac9-ac0c-59081c359dfd
# ╟─f3ddfc93-4f07-499e-9112-daff0b8dea71
# ╟─e64d924e-1187-4c1d-b9fc-d100e0323ab9
# ╟─09f38c05-9507-41df-b3da-5b720563e5bb
# ╟─8bbd7dcd-ba0e-4688-96a2-63a309e5c5b3
# ╟─1153343a-f61f-4ddb-ae11-41164062115c
# ╟─30bd80b0-213c-4358-a8dc-f7d2299fd4c3
# ╟─cd00e881-9e27-44ac-8334-d64255bbc3be
# ╟─1aad85e6-1a7d-41b4-9030-135d372dff58
# ╟─c428cca3-52c1-4e98-86b0-053518a81c46
# ╟─3a0b7467-e06d-45a6-86fa-c99e198137a6
# ╟─80be071d-89b4-460f-b3ca-51e1c5b7ac1b
# ╟─2876254b-3ad9-488e-9673-acceb7298de3
# ╟─42397cc5-5188-4208-8cf2-8e7b90d2b05b
# ╟─f07435a0-cc62-47ca-bdc2-55e2120220a3
# ╟─f0b6fb53-274d-48d5-902d-fca896e89813
# ╟─a94f0e2a-f0d4-41b5-bb86-b7107be07c3b
# ╟─241597f9-977e-4cb7-be70-256f52b97fdf
# ╟─ad984cbe-64ca-4632-974c-ff071af4860d
# ╟─fb3983ca-a035-456c-8287-772924e4222e
# ╟─2c89a8bd-ece5-4843-a1e5-422a8f71ba6b
# ╟─aa1f83b6-a767-481f-b2c1-fe238f40d969
# ╟─6cee6d3f-38bb-434f-81d4-c3c8a9cae530
# ╟─82b26083-1b70-4e2a-8313-375d136331d0
# ╟─056c331d-acc2-443f-b9a6-f76d46d740a8
# ╟─d842908e-59a0-42c5-8e7a-7dce812d42b4
# ╟─7c438487-5fd8-44fa-bc51-8cba228d950e
# ╟─81366ff1-314b-492a-bb41-0e2b2106ecd1
# ╟─9973cab2-eff7-4ebe-a223-abc258fb08f6
# ╟─81fa26da-ffe2-40e1-8dc2-ef466417d2a2
# ╟─91e59ee9-7736-4067-8eb2-4900b3930b29
# ╟─b5813779-1212-419c-aead-a25b4ff0a6af
# ╟─8ab51844-183b-4a35-a95d-561342fdfbfa
# ╟─130f1225-7bb8-41eb-a234-b33fd3c82e69
# ╟─0c3c21d0-070d-4b11-8570-a414610cd655
# ╟─6176eda8-06e7-4ca3-bd4d-cf21e816ec89
# ╟─b46f0d36-287c-4dba-8d9f-f0946948ae41
# ╟─af83328e-abd4-4005-adab-dcfd659e7a6f
# ╟─d1f4d03a-7289-4a0e-8ba0-6263ea3b82f5
# ╟─609a8d9c-9ca5-4d87-9c6e-f58f38183f80
# ╟─5c59b688-24e7-4242-a100-76196a867703
# ╟─6e1e6d2b-37a7-494c-ac85-a982fedf5af7
# ╟─52161fc1-a6ea-4d84-a236-982ab8b89373
# ╟─21bd8072-e942-4bfe-8c4e-3324f2e27c98
# ╟─c2ee0596-e2f8-4d9c-a72d-db38cce61dba
# ╟─2b3dc41a-4343-4682-80bc-f2d8b2e7a66f
# ╟─c46d8696-78aa-49f2-a28d-7c68ad583106
# ╟─cfda03e7-87c2-4418-8203-a768696ce5d1
# ╟─e5d2463f-780f-40de-a47b-c0528e0ce2c3
# ╟─33a18a43-9bed-4377-8f0c-9ddc2d9e3044
# ╟─4f4f686a-c1c4-4f2b-8758-0d5658a21599
# ╟─b54c4120-cd0c-4d39-b16b-2428551f23ec
# ╟─9c28bdfc-76ea-4125-9ca8-cc81007077e5
# ╟─9023c41b-6481-44b9-93d4-431460dfc5b5
# ╟─b6cb2bca-d1f1-42e2-9d5e-2517818f914d
# ╟─257f1590-9a62-43f8-b9b9-a878fb674bb2
# ╟─41f4bcb8-79b8-44ae-b1f4-9d77b41ea399
# ╟─f9f13e8f-070a-4696-98a7-25235cd65f6a
# ╟─c0233306-7dfd-4a50-b870-411cd76998cb
# ╟─714641c3-8e0a-4bc5-8f13-2ff57b1ad6d6
# ╟─7ed3b0c1-1557-4dd2-9065-e31e78dce2d3
# ╟─d6c0f8ff-06c6-493c-b9a6-6ebfa284382a
# ╟─732a841f-2a4e-4487-b29e-65ad09273a4e
# ╟─9c063461-886a-4f20-8854-67a059a1c775
# ╟─da630ce0-4135-4e53-9544-1506d18226c5
# ╟─3e616a98-236a-4c72-a1ee-6bb3b296a479
# ╟─72e204df-a22d-4280-8af9-153cbf69af0d
# ╟─eea75cb5-4461-407e-8ac3-5a79c088ebf3
# ╟─e1c1a6e9-0050-40be-9dfe-fe77f2444e17
# ╟─e555dbab-4f2a-4ca8-a29f-fe87541466ea
# ╟─f3ac1b29-5549-4505-a33c-4a9fe3067b6b
# ╟─4a6e7a75-eed3-4796-b42d-dbec4e184aed
# ╟─89fcb4d1-a469-47ad-9325-5a33fa53e4aa
# ╟─e3cd1f54-d3e5-4722-bdd8-9cb445ee5634
# ╟─3a556731-cbf6-4dbf-a7bf-02e1de8f0096
# ╟─1e6014b5-09d2-474c-9d21-154079c8aec2
# ╟─95c5cb60-39c1-439f-9451-cf1096715773
# ╟─d10007b6-1144-46bc-99f6-26dc458b69c6
# ╟─629390e6-b383-4b5d-84db-513c1be494f9
# ╟─685488f4-7218-4929-b41c-9d2cdf00fb00
# ╟─0b023c4d-64c9-4ed1-8dca-cc2dce2f9302
# ╟─67f40f7c-ef46-4a25-8c4d-751d2fb99ac8
# ╟─c9369621-acda-4bb2-a36a-f40665dc8943
# ╟─b4580191-b4ae-498c-a048-cd9e48fcde09
# ╟─588aa3cc-5c7b-4212-a34f-caf49babbee3
# ╟─ebe39eef-ee8e-4d06-9993-8ffb84a72f9f
# ╟─23d731aa-699a-48be-a8d2-b8c558538c71
# ╟─5988bfe0-a62d-4574-b844-1a8a965b15d0
# ╟─f5fd87c9-b016-4428-8530-518d8998f377
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
