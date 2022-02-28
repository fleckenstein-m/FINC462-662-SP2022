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

# ╔═╡ c3e429e4-e7e9-4db6-852c-906630f909a4
#Set-up packages
begin
	
	using DataFrames, Dates, DayCounts, PlutoUI, LaTeXStrings, HypertextLiteral
	
	import DayCounts: Thirty360, Actual360,Actual365Fixed,ActualActualISDA,ActualActualExcel, yearfrac
	
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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Exercise 03</b> <p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Bond Pricing Fundamentals</b> <p>
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

# ╔═╡ 3e995602-7a5e-45ce-a31d-449951af1aea
TableOfContents(aside=true, depth=1)

# ╔═╡ 4576f508-91bd-4fdc-a62d-833d8428f78f
md"""
# Question 1
"""

# ╔═╡ 6c57bd92-7d1d-41d3-88d5-0b2c191b7693
begin
	F1 = 1000
	P1 = 800
	T1 = 4
	Y1_SA = 2 * ((F1/P1)^(1/(2*T1))-1)
	Y1_A = (F1/P1)^(1/(T1))-1
	display("")
end

# ╔═╡ b7a00a1a-efcd-4dc3-9834-b4d02c83101a
md"""
Suppose a zero-coupon bond with face value of \$$(F1) and maturity date in $(T1) years from now sells for \$$(P1) today. Compute the yield to maturity of the zero coupon bond for a) semi-annual compounding, and b) annual compounding.
"""

# ╔═╡ 4e106888-54d6-4bc3-9eed-450c5dd41192
Markdown.parse("""
!!! hint
    a) Semi-annual compounding: ``$(roundmult(Y1_SA*100,1e-6))``%

	b) Annual compoundin: ``$(roundmult(Y1_A*100,1e-6))``%
""")

# ╔═╡ 3fdf2827-f5f9-4518-a7bf-946f4c215454
md"""
# Question 2
"""

# ╔═╡ 15a535bc-3808-4779-8123-40daa29014b9
begin
	Y2_01 = 0.04
	Y2_02 = 0.09
	c2 = 0.05
	F2 = 1000
	T2 = 1
	C2 = c2/2 * F2
	P2 = C2/(1+Y2_01/2)^(2*0.5) + (F2 + C2)/(1+Y2_02/2)^(2*1.0)
	display("")
end

# ╔═╡ dbf8f0f6-3ef9-41f3-acb3-fa47eedba00e
Markdown.parse("""
The yields on a six-month and a one-year Treasury STRIPS are $(Y2_01*100)%
and $(Y2_02*100)%, respectively. What would you be willing to pay for a $(c2*100)% Treasury note with principal value of \$ $(F2) and maturity in $(T2) year?

*Hint: Notice that we can replicate the cash flows of the $(c2*100)% Treasury note using the two Treasury STRIPS. Recall what the law of one price tells us.*
""")

# ╔═╡ 4fea0750-3b67-42f8-936f-b2fc2dbee784
Markdown.parse("""
!!! hint
    a) The fair price of the Treasury note is: ``$(roundmult(P2,1e-2))``
""")

# ╔═╡ 1202f4fc-d8e7-4fe8-9b39-f4c1a2eb5d0f
md"""
# Question 3
"""

# ╔═╡ 9ee1cabb-7101-4b48-b2f6-eba1dbe4f88d
md"""
Suppose you are reviewing a price sheet for bonds and you see the following prices (per \$100 par value) reported. You observe what seem to be several errors. Without calculating the price of each bond, indicate which bonds seem to be reported incorrectly.
"""

# ╔═╡ b566ae9c-7ce8-405c-b451-39669a1f339a
md"""
 Bond | Price  | Coupon Rate (%)  | Yield (%)
:-----|:-------|:-----------------|:-----------
U     | 90     | 6                | 9
V     | 96     | 9                | 8
W     | 110    | 8                | 6
X     | 105    | 0                | 5
Y     | 107    | 7                | 9
Z     | 100    | 6                | 6

"""

# ╔═╡ fa694855-ce3e-4436-8740-e8f2ad85f293
Markdown.parse("""
!!! hint
	- If the yield is the same as the coupon rate then the price of the bond should sell at its par value.
	  - This is the case of bond Z since par values are typical at or near a \\\$100 quote.
	- If the yield decreases below the coupon rate then the price of a bond should increase.
	  - This is the case for bond W. This is not the case for bond V so this bond is not reported correctly.
	- If the yield increases above the coupon rate then the price of a bond should decrease.
	  -This is the case for bond U.
	  - This is not the case for bonds X and Y so these bonds are not reported correctly.
	- Thus, bonds V, X, and Y are incorrectly reported because the change in the bond price is not consistent with the difference between the coupon rate and the yield.
""")

# ╔═╡ 2f003a31-8241-49af-af5a-f7110194316a
md"""
# Question 4
"""

# ╔═╡ 0b55c922-d5f2-499b-8c10-dd112a14d13d
begin
	SettleDt4 = Date(2022,05,15)
	MatDt4 = Date(2022,10,15)
	y4 = 0.06
	F4 = 100
	Days4 = Dates.value(MatDt4 - SettleDt4)
	T4 = Days4/365
	P4 = F4/(1+y4/2)^(2*T4)
	display("")
end

# ╔═╡ d837bac3-285b-4f83-833e-79445a37752e
Markdown.parse("""
Suppose you are given information about a Treasury STRIPS.
- Settlement: $(monthname(SettleDt4)) $(day(SettleDt4)), $(year(SettleDt4))
- Maturity Date: $(monthname(MatDt4)) $(day(MatDt4)),  $(year(MatDt4))
- Yield: $(y4*100) %

1. Calculate the number of days until maturity.
2. Calculate the time to maturity in (fractions of) years.
3. Calculate the full price of the Treasury STRIPS.
""")

# ╔═╡ fd94f48f-16fe-4a50-961e-ffb6105e0a1d
Markdown.parse("""
!!! hint
	1. ``$(Days4)`` days.
	2. ``$(roundmult(T4,1e-6))`` years.
	3. Full price: \\\$ ``$(roundmult(P4,1e-4))``
""")

# ╔═╡ 54c003e6-9030-4715-9ef1-411f146d54fd
md"""
# Question 5
"""

# ╔═╡ f03bc5f8-7bdc-4aae-8a9f-888c6a4d06c3
begin
	SettleDt5 = Date(2022,03,01)
	MatDt5 = Date(2022,11,15)
	F5 = 100
	P5 = 97.95
	Days5 = Dates.value(MatDt5 - SettleDt5)
	T5 = Days5/365
	y5 = 2*((F5/P5)^(1/(2*T5))-1)
	display("")
end

# ╔═╡ 05318942-5f55-43a0-ae12-0796ac3f2e39
Markdown.parse("""
Suppose you are given information about a Treasury STRIPS.
- Settlement: $(monthname(SettleDt5)) $(day(SettleDt5)),  $(year(SettleDt5))
- Maturity Date: $(monthname(MatDt5)) $(day(MatDt5)),  $(year(MatDt5))
- Price: \\\$ $(P5) 

1. Calculate the number of days until maturity.
2. Calculate the time to maturity in (fractions of) years.
3. Calculate the yield to maturity of the Treasury STRIPS.
""")

# ╔═╡ a9882d86-cfcf-446b-af5f-75a4084217d7
Markdown.parse("""
!!! hint
	1. ``$(Days5)`` days.
	2. ``$(roundmult(T5,1e-6))`` years.
	3. Yield to maturity: ``$(roundmult(y5*100,1e-6))``%
""")

# ╔═╡ c6308e8b-4a49-401c-964b-5e84ce20e19c
md"""
# Question 6
"""

# ╔═╡ 34acb9ef-0eae-4918-8f61-677bd9515fd8
begin
	SettleDt6 = Date(2009,10,31)
	MatDt6 = Date(2018,2,15)
	PrevCpnDate6 = Date(2009,8,15)
	NextCpnDate6 = Date(2010,2,15)
	c6 = 0.035
	F6 = 100
	y6 = 0.0323
	C6 = c6/2 * F6 #1
	daysFromPrev6 = yearfrac(PrevCpnDate6,SettleDt6,Thirty360())*360 
	daysToNext6 = yearfrac(SettleDt6,NextCpnDate6,Thirty360())*360 
	t1_6 = yearfrac(SettleDt6,NextCpnDate6,Thirty360())
	tT_6 = yearfrac(SettleDt6,MatDt6,Thirty360())
	daysInCpnPer6 = yearfrac(PrevCpnDate6,NextCpnDate6,Thirty360())*360 
	daysAccrued6 = daysInCpnPer6 - daysToNext6 
	yearsToMatPrevCpnDate6 = length(NextCpnDate6:Month(6):(MatDt6))/2
	DeltaT6 = daysAccrued6/360
	accrInt6 = daysAccrued6/daysInCpnPer6 * C6
	tVec6 = collect(t1_6:0.5:tT_6)
	P6 = sum(C6 ./ (1+y6/2).^(2 .* tVec6)) + 100/(1+y6/2)^(2*tT_6)
	P6Prev = C6/(y6/2) * (1-1/(1+y6/2)^(2*yearsToMatPrevCpnDate6)) + F6/(1+y6/2)^(2*yearsToMatPrevCpnDate6)
	display("")
end

# ╔═╡ f1a42f82-ddb4-4db9-a5d5-2b52616d1f97
Markdown.parse("""
Suppose Bond G is sold for settlement on $(monthname(SettleDt6)) $(day(SettleDt6)),  $(year(SettleDt6)), and you are given the following information.
- Annual Coupon Rate: $(roundmult(c6*100,1e-2)) %
- Coupon Payment Frequency: Semiannual
- Maturity Date: $(monthname(MatDt6)) $(day(MatDt6)),  $(year(MatDt6))
- Yield-to-Maturity: $(roundmult(y6*100,1e-4))%
- Face Value: \\\$$(F6)
- Day Count Convention: 30/360

1. Calculate the coupon cash flows (in dollars).
2. Calculate the number of days until the next coupon payment.
3. Calculate the number of days in the coupon period.
4. Calculate the number of days in the accrued interest interest period.
5. Calculate the accrued interest.
6. Calculate the time to the next coupon cash flow in (fractions of) years.
7. Calculate the time to maturity in (fractions of) years.
8. Calculate the full price of the bond.
""")

# ╔═╡ e7e878bc-9796-4543-8f27-bfd26236c9b7
Markdown.parse("""
!!! hint
	1. \\\$$(roundmult(C6,1e-2))
	2. $(roundmult(daysToNext6,1e-2)) days
	3. $(roundmult(daysInCpnPer6,1e-2)) days
	4. $(roundmult(daysAccrued6,1e-2)) days
	5. \\\$$(roundmult(accrInt6,1e-6))
	6. $(roundmult(t1_6,1e-4)) years
	7. $(roundmult(tT_6,1e-4)) years
	8. Calculation shown below.

	``P = \\frac{C}{(1+\\frac{y}{2})^{2\\times t_1}}
          + \\frac{C}{(1+\\frac{y}{2})^{2\\times t_2}}
		  + \\ldots
		  + \\frac{100 + C}{(1+\\frac{y}{2})^{2\\times t_T}}``
    - where ``t_1`` = time to the next coupon cash flow as a fraction of a year
    - ``t_2`` = ``t_1`` + 0.5
	- ``t_3`` = ``t_2`` + 0.5
    - ``\\ldots``
	- ``t_T`` = time to maturity as a fraction of years.

    Thus, 
	``P = \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6,1e-4))}}
          + \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6+0.5,1e-4))}}
		  + \\ldots
		  + \\frac{$(roundmult(100+C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(tT_6,1e-4))}}= \\\$$(roundmult(P6,1e-6))``
""")

# ╔═╡ 397e01d8-f220-4cc4-a000-27606342611d
md"""
#### Short-cut using the Annuity Formula
"""

# ╔═╡ 3b1e7bb4-e8e2-46b3-a345-3eb59dfc07e7
md"""
- As we have seen before, calculating the present value of all of the cash flows becomes tedious as the time to maturity increases.
- We learned how to use the annuity formula as a shortcut for bonds with maturities of T=0.5, 1.0, 1.5, 2.0, 2.5 etc. This worked well because we had an even number of 6-month coupon periods until maturity.
- Is it possible to use the annuity formula to find the price of a bond between coupon dates?
- The answer is generally no, but we will see that there is a short-cut which allows us to use the annuity formula.
"""

# ╔═╡ bedc53f0-4f33-4c25-9482-59d4c0e0b760
Markdown.parse("""
- Let's start with the last equation, which we used to calculate the bond price. 

``P = \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6,1e-4))}}
          + \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6+0.5,1e-4))}}
		  + \\ldots
		  + \\frac{$(roundmult(100+C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(tT_6,1e-4))}}= $(roundmult(P6,1e-6))``


""")

# ╔═╡ 1f9f2075-0767-49f2-b367-f52c9fe59501
Markdown.parse(""" 
- Let's now multiply the right-hand side by
``\\left(\\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{-2\\times $(roundmult(DeltaT6,1e-4))}} \\times \\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(DeltaT6,1e-4))}} \\right)``
- Note that this changes nothing, since the value of this term is one.

``P =\\left(\\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{-2\\times $(roundmult(DeltaT6,1e-4))}} \\times \\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(DeltaT6,1e-4))}} \\right) \\left(\\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6,1e-4))}}
          + \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(t1_6+0.5,1e-4))}}
		  + \\ldots
		  + \\frac{$(roundmult(100+C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(tT_6,1e-4))}}\\right)``

""")

# ╔═╡ 6ab5f78b-2962-45da-87f2-a5d4538a928b
Markdown.parse("""

- Next, notice that ``$(roundmult(DeltaT6,1e-4))+$(roundmult(t1_6,1e-4))=0.5``

``P =\\left(\\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{-2\\times $(roundmult(DeltaT6,1e-4))}}  \\right) \\left( \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(0.50,1e-4))}}
          + \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(1.0,1e-4))}}
		  + \\ldots
		  + \\frac{$(roundmult(C6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}}
         + \\frac{$(roundmult(F6,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}}\\right)``


""")

# ╔═╡ ad481434-dc85-44d0-901a-dd83f9ba6781
Markdown.parse("""
- Clearly, the term in parentheses is a bond for which we can use the annuity formula.

``P =\\left(\\frac{1}{(1+\\frac{$(roundmult(y6,1e-4))}{2})^{-2\\times $(roundmult(DeltaT6,1e-4))}}  \\right) 
		  \\times \\left( \\left[ \\frac{$(roundmult(C6,1e-2))}{\\frac{$(roundmult(y6,1e-2))}{2}} \\times \\left(1- \\frac{1}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}} \\right) \\right] + \\frac{$(roundmult(100,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}}\\right)``


""")

# ╔═╡ e63388ad-50e7-4122-99f8-d0ea79dc4d5c
Markdown.parse(""" 
- This is the same as

``P =\\left((1+\\frac{$(roundmult(y6,1e-4))}{2})^{2\\times $(roundmult(DeltaT6,1e-4))}  \\right) 
		  \\times \\left( \\left[ \\frac{$(roundmult(C6,1e-2))}{\\frac{$(roundmult(y6,1e-2))}{2}} \\times \\left(1- \\frac{1}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}} \\right) \\right] + \\frac{$(roundmult(100,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}}\\right)``

""")

# ╔═╡ 46d52a96-2a64-4512-9033-77e294ed89d4
Markdown.parse(""" 
- This means that we can use the following step-by-step approach.

**Step-by-Step Approach**
1. Assume that we are on the previous coupon date.
2. Calculate the price of the bond using the time to maturity on the previous coupon date (but keeping the coupon rate, face value, and yield the same).
3. Multiply the result by  ``(1+\\frac{y}{2})^{2\\times \\Delta t}`` where ``\\Delta t`` is the number of days from the previous coupon date (up to but excluding the settlement date), expressed as a fraction of a year.

""")

# ╔═╡ 810ba86d-c7d9-4b8f-ba8f-2911fea40f28
md"""
- Let's walk through this approach one step at a time.
"""

# ╔═╡ 7ef16a5e-298c-47a6-b0a8-8b69ba8c5e8c
Markdown.parse("""
**Step 1**
1. Assume that you are on the previous coupon date: $(monthname(PrevCpnDate6)) $(day(PrevCpnDate6)), $(year(PrevCpnDate6)).
	
On the previous coupon date, there are $(yearsToMatPrevCpnDate6) years to maturity.

**Step 2**
2. Calculate the price of the bond using the time to maturity on the previous coupon date (but keeping the coupon rate, face value, and yield the same).
	
``P_{prev} = \\frac{$(roundmult(C6,1e-2))}{\\frac{$(roundmult(y6,1e-2))}{2}} \\times \\left(1- \\frac{1}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}} \\right)  + \\frac{$(roundmult(100,1e-2))}{(1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate6,1e-4))}}= $(roundmult(P6Prev,1e-6))``
	
**Step 3**	
3. Multiply the result by  ``(1+\\frac{y}{2})^{2\\times \\Delta t}`` where ``\\Delta t`` is the number of days from the previous coupon date (up to but excluding the settlement date), expressed as a fraction of a year.
	
There are $(roundmult(daysAccrued6,1e-2)) days in the accrued interest period. Hence,
	``\\Delta t = \\frac{$(roundmult(daysAccrued6,1e-2))}{360}=$(roundmult(DeltaT6,1e-6))``.
	
``P = (1+\\frac{y}{2})^{2\\times \\Delta t} \\times P_{prev} = (1+\\frac{$(roundmult(y6,1e-2))}{2})^{2\\times $(roundmult(DeltaT6,1e-4))} = $(roundmult((1+y6/2)^(2*DeltaT6)*P6Prev,1e-6))``

- Clearly, we get the same result for the bond price as before.
""")

# ╔═╡ 62dfb779-db1a-410b-86eb-ebe514cea6b9
md"""
# Question 7
"""

# ╔═╡ 9d861904-0496-43be-9d1b-d90862bb33a8
begin
	SettleDt7 = Date(2018,5,15)
	MatDt7 = Date(2027,10,15)
	PrevCpnDate7 = Date(2018,4,15)
	NextCpnDate7 = Date(2018,10,15)
	c7 = 0.08
	F7 = 100
	y7 = 0.06
	C7 = c7/2 * F7 #1
	daysFromPrev7 = yearfrac(PrevCpnDate7,SettleDt7,Thirty360())*360 
	daysToNext7 = yearfrac(SettleDt7,NextCpnDate7,Thirty360())*360 
	t1_7 = yearfrac(SettleDt7,NextCpnDate7,Thirty360())
	tT_7 = yearfrac(SettleDt7,MatDt7,Thirty360())
	daysInCpnPer7 = yearfrac(PrevCpnDate7,NextCpnDate7,Thirty360())*360 
	daysAccrued7 = daysInCpnPer7 - daysToNext7 
	yearsToMatPrevCpnDate7 = length(NextCpnDate7:Month(6):(MatDt7))/2
	DeltaT7 = daysAccrued7/360
	accrInt7 = daysAccrued7/daysInCpnPer7 * C7
	tVec7 = collect(t1_7:0.5:tT_7)
	P7 = sum(C7 ./ (1+y7/2).^(2 .* tVec7)) + 100/(1+y7/2)^(2*tT_7)
	P7Prev = C7/(y7/2) * (1-1/(1+y7/2)^(2*yearsToMatPrevCpnDate7)) + F7/(1+y7/2)^(2*yearsToMatPrevCpnDate7)
	display("")
end

# ╔═╡ 63bfb4ce-2e95-492c-99d2-2134fe12dd48
Markdown.parse("""
Suppose Bond H is sold for settlement on $(monthname(SettleDt7)) $(day(SettleDt7)),  $(year(SettleDt7)), and you are given the following information.
- Annual Coupon Rate: $(roundmult(c7*100,1e-2)) %
- Coupon Payment Frequency: Semiannual
- Maturity Date: $(monthname(MatDt7)) $(day(MatDt7)),  $(year(MatDt7))
- Yield-to-Maturity: $(roundmult(y7*100,1e-4))%
- Face Value: \\\$$(F7)
- Day Count Convention: 30/360 

1. Calculate the coupon cash flows (in dollars).
2. Calculate the number of days until the next coupon payment.
3. Calculate the number of days in the coupon period.
4. Calculate the number of days in the accrued interest interest period.
5. Calculate the accrued interest.
6. Calculate the time to the next coupon cash flow in (fractions of) years.
7. Calculate the time to maturity in (fractions of) years.
8. Calculate the full price of the bond.
""")

# ╔═╡ 24f872e4-5b56-461b-8a43-3b1484b93fc6
Markdown.parse("""
!!! hint
	1. \\\$$(roundmult(C7,1e-2))
	2. $(roundmult(daysToNext7,1e-2)) days
	3. $(roundmult(daysInCpnPer7,1e-2)) days
	4. $(roundmult(daysAccrued7,1e-2)) days
	5. \\\$$(roundmult(accrInt7,1e-6)) 
	6. $(roundmult(t1_7,1e-4)) years
	7. $(roundmult(tT_7,1e-4)) years
	8. Calculation shown below.
	``P = \\frac{$(roundmult(C7,1e-2))}{(1+\\frac{$(roundmult(y7,1e-4))}{2})^{2\\times $(roundmult(t1_7,1e-4))}}
          + \\frac{$(roundmult(C7,1e-2))}{(1+\\frac{$(roundmult(y7,1e-4))}{2})^{2\\times $(roundmult(t1_7+0.5,1e-4))}}
		  + \\ldots
		  + \\frac{$(roundmult(100+C7,1e-2))}{(1+\\frac{$(roundmult(y7,1e-2))}{2})^{2\\times $(roundmult(tT_7,1e-4))}}= \\\$$(roundmult(P7,1e-6))``
""")

# ╔═╡ 72fb7d67-ae75-4260-9c4f-e825223a62ed
md"""
#### Short-cut using the Annuity Formula
"""

# ╔═╡ 16457ba6-80cc-4952-9477-9bcf24660ea7
Markdown.parse("""
!!! hint
	
	**Step-by-Step Approach**
	1. Assume that you are on the previous coupon date: $(monthname(PrevCpnDate7)) $(day(PrevCpnDate7)), $(year(PrevCpnDate7)).
	
	On the previous coupon date, there are $(yearsToMatPrevCpnDate7) years to maturity.
	
	2. Calculate the price of the bond using the time to maturity on the previous coupon date (but keeping the coupon rate, face value, and yield the same).
	
	``P_{prev} = \\frac{$(roundmult(C7,1e-2))}{\\frac{$(roundmult(y7,1e-2))}{2}} \\times \\left(1- \\frac{1}{(1+\\frac{$(roundmult(y7,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate7,1e-4))}} \\right)  + \\frac{$(roundmult(100,1e-2))}{(1+\\frac{$(roundmult(y7,1e-2))}{2})^{2\\times $(roundmult(yearsToMatPrevCpnDate7,1e-4))}}= $(roundmult(P7Prev,1e-6))``
	
	
	3. Multiply the result by  ``(1+\\frac{y}{2})^{2\\times \\Delta t}`` where ``\\Delta t`` is the number of days from the previous coupon date (up to but excluding the settlement date), expressed as a fraction of a year.
	
	There are $(roundmult(daysAccrued7,1e-2)) days in the accrued interest period. Hence,
	``\\Delta t = \\frac{$(roundmult(daysAccrued7,1e-2))}{360}=$(roundmult(DeltaT7,1e-7))``.
	
	``P = (1+\\frac{y}{2})^{2\\times \\Delta t} \\times P_{prev} = (1+\\frac{$(roundmult(y7,1e-2))}{2})^{2\\times $(roundmult(DeltaT7,1e-4))} = $(roundmult((1+y7/2)^(2*DeltaT7)*P7Prev,1e-6))``

""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
DayCounts = "44e31299-2c53-5a9b-9141-82aa45d7972f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFrames = "~1.2.2"
DayCounts = "~0.1.0"
HypertextLiteral = "~0.9.1"
LaTeXStrings = "~1.2.1"
PlutoUI = "~0.7.16"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

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

[[DayCounts]]
deps = ["Dates"]
git-tree-sha1 = "cb81cac5f32b71d4e127f4d1bea6fd6049e729b2"
uuid = "44e31299-2c53-5a9b-9141-82aa45d7972f"
version = "0.1.0"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

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

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "98f59ff3639b3d9485a03a72f3ab35bab9465720"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.6"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "69fd065725ee69950f3f58eceb6d144ce32d627d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─41d7b190-2a14-11ec-2469-7977eac40f12
# ╟─c3e429e4-e7e9-4db6-852c-906630f909a4
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3e995602-7a5e-45ce-a31d-449951af1aea
# ╟─4576f508-91bd-4fdc-a62d-833d8428f78f
# ╟─6c57bd92-7d1d-41d3-88d5-0b2c191b7693
# ╟─b7a00a1a-efcd-4dc3-9834-b4d02c83101a
# ╟─4e106888-54d6-4bc3-9eed-450c5dd41192
# ╟─3fdf2827-f5f9-4518-a7bf-946f4c215454
# ╟─15a535bc-3808-4779-8123-40daa29014b9
# ╟─dbf8f0f6-3ef9-41f3-acb3-fa47eedba00e
# ╟─4fea0750-3b67-42f8-936f-b2fc2dbee784
# ╟─1202f4fc-d8e7-4fe8-9b39-f4c1a2eb5d0f
# ╟─9ee1cabb-7101-4b48-b2f6-eba1dbe4f88d
# ╟─b566ae9c-7ce8-405c-b451-39669a1f339a
# ╟─fa694855-ce3e-4436-8740-e8f2ad85f293
# ╟─2f003a31-8241-49af-af5a-f7110194316a
# ╟─0b55c922-d5f2-499b-8c10-dd112a14d13d
# ╟─d837bac3-285b-4f83-833e-79445a37752e
# ╟─fd94f48f-16fe-4a50-961e-ffb6105e0a1d
# ╟─54c003e6-9030-4715-9ef1-411f146d54fd
# ╟─f03bc5f8-7bdc-4aae-8a9f-888c6a4d06c3
# ╟─05318942-5f55-43a0-ae12-0796ac3f2e39
# ╟─a9882d86-cfcf-446b-af5f-75a4084217d7
# ╟─c6308e8b-4a49-401c-964b-5e84ce20e19c
# ╟─34acb9ef-0eae-4918-8f61-677bd9515fd8
# ╟─f1a42f82-ddb4-4db9-a5d5-2b52616d1f97
# ╟─e7e878bc-9796-4543-8f27-bfd26236c9b7
# ╟─397e01d8-f220-4cc4-a000-27606342611d
# ╟─3b1e7bb4-e8e2-46b3-a345-3eb59dfc07e7
# ╟─bedc53f0-4f33-4c25-9482-59d4c0e0b760
# ╟─1f9f2075-0767-49f2-b367-f52c9fe59501
# ╟─6ab5f78b-2962-45da-87f2-a5d4538a928b
# ╟─ad481434-dc85-44d0-901a-dd83f9ba6781
# ╟─e63388ad-50e7-4122-99f8-d0ea79dc4d5c
# ╟─46d52a96-2a64-4512-9033-77e294ed89d4
# ╟─810ba86d-c7d9-4b8f-ba8f-2911fea40f28
# ╟─7ef16a5e-298c-47a6-b0a8-8b69ba8c5e8c
# ╟─62dfb779-db1a-410b-86eb-ebe514cea6b9
# ╟─9d861904-0496-43be-9d1b-d90862bb33a8
# ╟─63bfb4ce-2e95-492c-99d2-2134fe12dd48
# ╟─24f872e4-5b56-461b-8a43-3b1484b93fc6
# ╟─72fb7d67-ae75-4260-9c4f-e825223a62ed
# ╟─16457ba6-80cc-4952-9477-9bcf24660ea7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
