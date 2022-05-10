### A Pluto.jl notebook ###
# v0.19.3

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
	
	using DataFrames, Dates, PlutoUI, Printf, LaTeXStrings, HypertextLiteral, Statistics
	

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

# ╔═╡ 731c88b4-7daf-480d-b163-7003a5fbd41f
begin 
	html"""
	<p align=left style="font-size:36px; font-family:family:Georgia"> <b> FINC 462/662 - Fixed Income Securities</b> <p>
	"""
end

# ╔═╡ 19b58a85-e443-4f5b-a93a-8d5684f9a17a
TableOfContents(title="Exercise 07", indent=true, depth=2, aside=true)

# ╔═╡ a5de5746-3df0-45b4-a62c-3daf36f015a5
begin 
	html"""
	<p style="padding-bottom:1cm"> </p>
	<div align=center style="font-size:25px; font-family:family:Georgia"> FINC-462/662: Fixed Income Securities </div>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Exercise 08
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

# ╔═╡ 7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
md"""
# Question 1
"""

# ╔═╡ caad8479-654b-4a15-a994-56c8764728c7
begin
	r05_2 = 2.00
	r10_2 = 3.00
	r15_2 = 3.50
	r20_2 = 3.00
	r25_2 = 4.00 
	r30_2 = 4.50
	r35_2 = 4.75
	r40_2 = 5.00
	r45_2 = 5.10
	r50_2 = 5.25
	
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

	
	f10_30_2 = (((1+r30_2/200)^(2*3)/(1+r10_2/200)^(2*1))^(1/(2*2))-1)*2
	f20_40_2 = (((1+r40_2/200)^(2*4)/(1+r20_2/200)^(2*2))^(1/(2*2))-1)*2
	f30_50_2 = (((1+r30_2/200)^(2*5)/(1+r30_2/200)^(2*3))^(1/(2*2))-1)*2

	f10_50_2 = (((1+r50_2/200)^(2*5)/(1+r10_2/200)^(2*1))^(1/(2*4))-1)*2
	f20_50_2 = (((1+r50_2/200)^(2*5)/(1+r20_2/200)^(2*2))^(1/(2*3))-1)*2
	
	
	strf05_10_2 = "2*((1+$(roundmult(r10_2/100,1e-6))/2)^{2*1.0}/(1+$(r05_2/100)/2)^{2*0.5} -1)"
	strf10_15_2 = "2*((1+$(roundmult(r15_2/100,1e-6))/2)^{2*1.5}/(1+$(r10_2/100)/2)^{2*1.0} -1)"
	strf15_20_2 = "2*((1+$(roundmult(r20_2/100,1e-6))/2)^{2*2.0}/(1+$(r15_2/100)/2)^{2*1.5} -1)"
	strf20_25_2 = "2*((1+$(roundmult(r25_2/100,1e-6))/2)^{2*2.5}/(1+$(r20_2/100)/2)^{2*2.0} -1)"
	strf25_30_2 = "2*((1+$(roundmult(r30_2/100,1e-6))/2)^{2*3.0}/(1+$(r25_2/100)/2)^{2*2.5} -1)"
	strf30_35_2 = "2*((1+$(roundmult(r35_2/100,1e-6))/2)^{2*3.5}/(1+$(r30_2/100)/2)^{2*3.0} -1)"
	strf35_40_2 = "2*((1+$(roundmult(r40_2/100,1e-6))/2)^{2*4.0}/(1+$(r35_2/100)/2)^{2*3.5} -1)"
	strf40_45_2 = "2*((1+$(roundmult(r45_2/100,1e-6))/2)^{2*4.5}/(1+$(r40_2/100)/2)^{2*4.0} -1)"
	strf45_50_2 = "2*((1+$(roundmult(r50_2/100,1e-6))/2)^{2*5.0}/(1+$(r45_2/100)/2)^{2*4.5} -1)"
	strfVec_2 = [strf05_10_2,strf10_15_2,strf15_20_2,strf20_25_2,strf25_30_2,strf30_35_2,strf35_40_2,strf40_45_2,strf45_50_2]
	display("")	
end

# ╔═╡ 23bb9890-718d-42fd-a9fa-51b4a7994ed7
md"""
Suppose spot rates are as given below. Calculate 6-month forward rates out to 5 years, i.e. calculate $f_{0.5,1}$, $f_{1.0,1.5}$, ..., $f_{4.5,5}$.

| Tenor $\,T$ | Spot Rate $\,r_t$      |
|:----------|:--------------------|
| 0.5-year  | $r_{0.5}$=$(r05_2)% |
| 1.0-year  | $r_{1.0}$=$(r10_2)%
| 1.5-year  | $r_{1.5}$=$(r15_2)%
| 2.0-year  | $r_{2.0}$=$(r20_2)%
| 2.5-year  | $r_{2.5}$=$(r25_2)%
| 3.0-year  | $r_{3.0}$=$(r30_2)%
| 3.5-year  | $r_{3.5}$=$(r35_2)%
| 4.0-year  | $r_{4.0}$=$(r40_2)%
| 4.5-year  | $r_{4.5}$=$(r45_2)%
| 5.0-year  | $r_{5.0}$=$(r50_2)%

"""

# ╔═╡ ac0cf027-4684-4e1e-87df-ac66ecc17461
Markdown.parse("
!!! correct

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

# ╔═╡ 4302072c-2542-4901-8c3d-ba6170af3744
md"""
# Question 2
"""

# ╔═╡ a473c4cd-0a21-493b-9ec5-55ea66a0ed99
Markdown.parse("
__2.1__ Calculate the two-year forward rate starting one year from today (i.e., \$f_{1,3}\$).
")

# ╔═╡ 1c95f7b3-6ff5-4b5e-bc26-4bf80d98425e
Markdown.parse("
!!! correct
	``\$\\left( 1+ \\frac{f_{1,3}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,3}}{2}\\right)^{2\\times 3}}{\\left( 1+ \\frac{r_{0,1}}{2}\\right)^{2\\times 1}}\$``
	
	``\$\\left( 1+ \\frac{f_{1,3}}{2}\\right)^{4}  = \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2}}\$``
	
	``\$f_{1,3} = 2\\times \\left( \\frac{\\left(1+ \\frac{$(r30_2)\\%}{2}\\right)^{6/4}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2/4}} -1\\right)\$``
	
	``\$ f_{1,3} = $(roundmult(f10_30_2,1e-6)) = $(roundmult(f10_30_2*100,1e-4)) \\%\$``
")

# ╔═╡ 5d00ce86-142d-4740-91e1-73704382c366
Markdown.parse("
__2.2__ Calculate the two-year forward rate starting two years from today (i.e., \$f_{2,4}\$).
")

# ╔═╡ 40079ad2-79a8-4d15-906e-b4fdd8b6a88d
Markdown.parse("
!!! correct
	``\$\\left( 1+ \\frac{f_{2,4}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,4}}{2}\\right)^{2\\times 4}}{\\left( 1+ \\frac{r_{0,2}}{2}\\right)^{2\\times 2}}\$``
	
	``\$\\left( 1+ \\frac{f_{2,4}}{2}\\right)^{4}  = \\frac{\\left(1+ \\frac{$(r40_2)\\%}{2}\\right)^{8}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{4}}\$``
	
	``\$f_{2,4} = 2\\times \\left( \\frac{\\left(1+ \\frac{$(r40_2)\\%}{2}\\right)^{8/4}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{4/4}} -1\\right)\$``
	
	``\$f_{2,4} = $(roundmult(f20_40_2,1e-6)) = $(roundmult(f20_40_2*100,1e-4))\\%\$``
")

# ╔═╡ 5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
Markdown.parse("
__2.3__ Calculate the two-year forward rate starting three years from today (i.e., \$f_{3,5}\$).
")

# ╔═╡ d43cdfc5-a6fe-423b-83c7-522026fd6097
Markdown.parse("
!!! correct
	``\$\\left( 1+ \\frac{f_{3,5}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,3}}{2}\\right)^{2\\times 3}}\$``
	
	``\$\\left( 1+ \\frac{f_{3,5}}{2}\\right)^{2\\times 2}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r30_2)\\%}{2}\\right)^{2\\times 3}}\$``
	
	``\$f_{3,5} = $(roundmult(f30_50_2,1e-6)) = $(roundmult(f30_50_2*100,1e-4))\\%\$``
")

# ╔═╡ d74dd608-b367-43f3-b5f1-bd654e5f87e2
Markdown.parse("
__2.4__ Calculate the 4-year forward rate starting one year from today (i.e., \$f_{1,5}\$).
")

# ╔═╡ 9b10cdd6-ba85-49f5-87cd-d018a301b3af
Markdown.parse("
!!! correct
	``\$\\left( 1+ \\frac{f_{1,5}}{2}\\right)^{2\\times 4}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,1}}{2}\\right)^{2\\times 1}}\$``
	
	``\$\\left( 1+ \\frac{f_{1,5}}{2}\\right)^{2\\times 4}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r10_2)\\%}{2}\\right)^{2\\times 1}}\$``
	
	``\$f_{1,5} = $(roundmult(f10_50_2,1e-6)) = $(roundmult(f10_50_2*100,1e-4))\\%\$``
")

# ╔═╡ 18252fe4-6aba-4b13-b6fb-6426bd9037ca
Markdown.parse("
__2.5__ Calculate the 3-year forward rate starting two years from today (i.e., \$f_{2,5}\$).
")

# ╔═╡ 16610ace-58fc-4619-a99c-90575607c1c0
Markdown.parse("
!!! correct
	``\$\\left( 1+ \\frac{f_{2,5}}{2}\\right)^{2\\times 3}  = \\frac{\\left(1+ \\frac{r_{0,5}}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{r_{0,2}}{2}\\right)^{2\\times 2}}\$``
	
	``\$\\left( 1+ \\frac{f_{2,5}}{2}\\right)^{2\\times 3}  = \\frac{\\left(1+ \\frac{$(r50_2)\\%}{2}\\right)^{2\\times 5}}{\\left( 1+ \\frac{$(r20_2)\\%}{2}\\right)^{2\\times 2}}\$``
	
	``\$f_{2,5} = $(roundmult(f20_50_2,1e-6)) = $(roundmult(f20_50_2*100,1e-4))\\%\$``
")

# ╔═╡ ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
md"""
# Question  3
"""

# ╔═╡ c6270f22-51dc-44a9-80b9-ccd10dbc41ac
md"""
On May 15, 2000, you enter into a forward rate agreement (notional =
\$100 million) with a bank for the period from November 15, 2000 to May 15,
2001 (6 months later to 1 year later). The current price of a
6-month zero coupon bond is \$96.79 and the current price of a
1-year zero coupon bond is \$93.51. Assume semi-annual compounding.

"""

# ╔═╡ 4a8ce7d3-0315-4d13-9734-c47f7b87d21b
md"""
__3.1__ What must the forward rate agreed upon be so that there is no arbitrage?
"""

# ╔═╡ f74312b3-54f7-4d3f-902e-3eb6494fc236
md"""
!!! correct
	First, solve for the yields on the 6-month and the 1-year zero coupon bonds.
	- 6mo zero: P=\$96.79

	$$r_{0.5}=2\times \left(\left(\frac{100}{96.79}\right)^{\frac{1}{2\times 0.5}} -1 \right)=0.066329166=6.6329\%$$

	- 1yr zero: P=\$93.51

	$$r_{1.0}=2\times \left(\left(\frac{100}{93.51}\right)^{\frac{1}{2\times 1}} -1 \right)=0.068240161=6.82402\%$$

	Next, solve for $f_{0.5,1}$

	$$\left(1+\frac{r_{0.5}}{2}\right)\left(1+\frac{f_{0.5,1}}{2}\right) = \left(1+\frac{r_1}{2}\right)^2$$

	Solving theis equation for the forward rates gives us

    $$f_{0.5,1} = 7.015925\%$$

	Thus, you will pay \$100mm in Nov 2000 to receive
	$100 \times \left(1+\frac{0.0701592}{2}\right) = 103.51$ million
	in May 2001.
	

"""

# ╔═╡ 95a7fe7f-f580-4f26-b47e-a5dac16d49f5
md"""
__3.2__  What is the value of the forward at inception?
"""

# ╔═╡ 719d529a-03e4-4f1b-a438-6dcfa57deec3
md"""
!!! correct
    The value of the forward at inception is 0.

"""

# ╔═╡ 16f078b5-a050-4876-9048-a06d3e2733be
md"""
__3.3__ Suppose that three months have passed, so it is August 15, 2000. You are given the following discount factors.

- August 15, 2000

|Maturity       |   $D(0,T)$
|:--------------|:---------
|Nov 2000 (3mo) |   0.9844
|Feb 2001 (6mo) |   0.9690
|May 2001 (9mo) |   0.9531
|Aug 2001 (12mo)|   0.9386

What is the value of the forward agreement? 

*Hint: Think about what the cashflows to the forward agreement are.*

"""

# ╔═╡ 765e386b-be08-43d0-ac71-a62d0ebf23c7
md"""
!!! correct

	Though the value of the forward at inception was 0, interest
	rates have changed since the forward rate agreement was made.
	The most straightforward way to calculate the value of the
	position is to write out the future cashflows and discount back
	to today.
	
	  
	| Time t                  | t = 0.25 (Nov 2000)  | t = 0.75 (May 2001) |
	|:------------------------|:---------------------|:--------------------|
	| Forward Rate Agreement  |                -100  |              103.51 |
	
	
	- Value of forward rate agreement:

	$$-100 \times 0.9844 + 103.51 \times 0.9531 = 0.215$$
"""

# ╔═╡ eb77b6e7-2890-447a-98c7-74b581af4dd9
md"""
__3.4__ Now consider November 15, 2000. What is the value of the forward agreement now?

| Maturity         |  $D(0,T)$ |
|:-----------------|:--------|
| Feb 2001 (3mo)   | 0.9848  | 
| May 2001 (6mo)   | 0.9692  |
| Aug 2001 (9mo)   | 0.9545  |
| Nov 2001 (12mo)  | 0.9402  |
"""

# ╔═╡ f63ea571-6452-42c1-af7e-4fb789304a2d
md"""
!!! correct
	  
	| Time t                  | t = 0.0 (Nov 2000)   | t = 0.50 (May 2001) |
	|:------------------------|:---------------------|:--------------------|
	| Forward Rate Agreement  |                -100  |              103.51 |
	
	
	- Value of forward rate agreement:

	$$-100 + 103.51 \times 0.9692 = 0.32$$

"""

# ╔═╡ f61fc2af-e411-4075-bcda-3fd761da58cb
md"""
__3.5__ What is the six-month spot rate (semi-annually compounded) now?
"""

# ╔═╡ 3e75a33e-392b-4fd0-9978-07fad6a4faf1
md"""
!!! correct

	Recall that the spot rate can be calculated from the discount factor $D(T)$ using

	$$D(T)=\frac{1}{(1+\frac{r_{T}}{2})^{2\times T}}$$

	Plugging in $D(T=0.5)=0.9692$ gives us

	$$r_{0.5} = 2\times \left( \left(\frac{1}{0.9692}\right)^{\frac{1}{2\times 0.5}} -1\right) = 0.0635557573 = 6.36\%$$
"""

# ╔═╡ 82fe8645-a213-44ed-919d-18b0cbb0eeae
md"""
__3.6__ What is the cash flow in May 2001 if you invest \$100 million at the spot rate in Nov. 2000? Compare this to agreeing to the original forward rate agreement.
"""

# ╔═╡ 0e1c20db-5322-4f38-b9e0-f9333b8b743b
md"""
!!! correct

	- Investing in the spot rate:

	$$100 \times \left(1+\frac{0.0636}{2}\right)=103.18$$

	- Had we agree to the forward rate, we would invest at a rate of 7.016%.

	$$100\times \left(1+\frac{0.07016}{2}\right)=103.51$$

"""

# ╔═╡ 3713b423-0ef4-4685-a22d-39ae73dbb094
md"""
# Question 4
"""

# ╔═╡ f41b3285-6ff5-4f16-b936-eca01600b5b4
md"""
Suppose the one-year spot interest rate is 4% and the two-year spot rate is 5%. Assume that all rates are annually compounded.

__4.1__ What is the forward rate at time 0 for borrowing at time 1 for one year (i.e. compute $f_{1,2}$)?
"""

# ╔═╡ 04feec75-3fdd-4a32-9010-7cccf2e93d57
md"""
!!! correct
    The forward rate is given by $$f_{1,2}=\frac{1.05^2}{1.04}=6.01$$%.
"""

# ╔═╡ 2f641623-6c1c-476b-a57a-ebee39739137
md"""
__4.2__ Now suppose you want to borrow \$100 for one year one year from now and want to lock in the interest rate today. What investment strategy would you need to follow if you have access to the spot markets only (i.e. how can you synthetically replicate the forward contract using one-year and two-year zero coupon bonds)?
"""

# ╔═╡ 7958f21a-63af-47c8-9e7d-31a89ffa1645
md"""
!!! correct
	You want to implement a trading strategy that gives you \$100 one year from now, which you have to repay two years from now at the interest rate $f_{1,2}=6.01$%. The cash flow structure looks as follows:
	
	| T | 0 | 1 | 2 |
	| --- | --- | --- | --- |
	| Forward Contract | 0 | +$100 | -\$100 $\times$ (1.0601) |
	
	We can replicate this cash flow by investing $\frac{100}{1.04}$=\$96.15 for one year in $t=0$ and borrowing this amount for two years with a repayment of $96.15\times 1.05^2=$\$106.01. The trading strategy can be depicted as follows:
	
	| T | 0 | 1 | 2 |
	| --- | --- | --- | --- |
	| Investing for one Year | -\$96.15 | +\$100 | 0 |
	| Borrowing for two years | +\$96.15 | 0 | -\$106.01 |
	| Total | 0 | +\$100 | -\$106.01 |
	
	A combination of these two positions yields the same cash flows as a forward contract.
"""

# ╔═╡ ccbfccc4-f3fd-4c86-a61e-7f6a2a0cf79b
md"""
__4.3__ Now both spot and forward contracts are traded. Suppose the forward rate was 5.5%. Explain how you could exploit this situation to make money without risk.
"""

# ╔═╡ 0eb1aa68-5c3a-46c8-9c29-c1288316d57c
md"""
!!! correct
	There are two ways to borrow money for two years. You can either borrow for two years in the spot market or borrow in the spot market for one year and enter into a forward contract for one more year. The cash flows from both strategies are known at t=0. 

	The two-year interest rate implied by the latter strategy is $\sqrt{1.04\times1.055}-1=4.75\%$. 

	That means you can borrow using the spot and future markets and then invest the proceeds for two years in the spot markets. This strategy involves no money up front but provides a cash flow at t=2. The following table clarifies this point.
	
	| t | 0 | 1 | 2 |
	| --- | --- | --- | --- |
	| Borrowing for one year in the spot market | +$100 | -$104 | 0 |
	| Borrowing from the forward market | 0 | +$104 | -$104\times1.055=$109.72 |
	| Investing for two years in the spot market | -$100 | 0 | +$110.25 |
	| Total | 0 | 0 | +$0.53 |
	
	
"""

# ╔═╡ d6a1eca6-19da-411d-bcc7-cd2167678908
md"""
# Question 5
"""

# ╔═╡ ca61760e-9156-4d81-834e-e41c747e1e43
md"""
A one-year zero coupon bond with \$100 face value is currently trading for \$98. The forward rate for borrowing money one year from now for another year is 6%. Compute the arbitrage free two-year spot rate. Assume annual compounding.
"""

# ╔═╡ ece3723e-57a3-4cbc-8c36-9ee8ddc7130c
md"""
!!! correct
	
	The yield on the one-year zero coupon bond trading at \$98 is

	$$y_1 = \left(\frac{100}{98}\right)-1=2.04\%$$
		
	Rolling this investment over after year one at the forward rate of 6% must give you the same return as investing today at the 2-year spot rate. That means,
	
	$$(2+y_1)\times (1+f_{1,2})=(1+y_2)^2$$
	
	Solving for the two year spot rate gives us

	$$y_2 = \sqrt{(1+y_1)\times(1+f_{1,2})}=4.00\%$$
	
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
DataFrames = "~1.3.2"
HypertextLiteral = "~0.9.3"
LaTeXStrings = "~1.3.0"
PlutoUI = "~0.7.37"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

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

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

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
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

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
deps = ["Libdl"]
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

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "85b5da0fa43588c75bb1ff986493443f821c70b7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.3"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "bf0a1121af131d9974241ba53f601211e9303a9e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.37"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

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

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─19b58a85-e443-4f5b-a93a-8d5684f9a17a
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─23bb9890-718d-42fd-a9fa-51b4a7994ed7
# ╟─caad8479-654b-4a15-a994-56c8764728c7
# ╟─ac0cf027-4684-4e1e-87df-ac66ecc17461
# ╟─4302072c-2542-4901-8c3d-ba6170af3744
# ╟─a473c4cd-0a21-493b-9ec5-55ea66a0ed99
# ╟─1c95f7b3-6ff5-4b5e-bc26-4bf80d98425e
# ╟─5d00ce86-142d-4740-91e1-73704382c366
# ╟─40079ad2-79a8-4d15-906e-b4fdd8b6a88d
# ╟─5f84a5be-dbea-4eab-ba5a-06b8062d5b4b
# ╟─d43cdfc5-a6fe-423b-83c7-522026fd6097
# ╟─d74dd608-b367-43f3-b5f1-bd654e5f87e2
# ╟─9b10cdd6-ba85-49f5-87cd-d018a301b3af
# ╟─18252fe4-6aba-4b13-b6fb-6426bd9037ca
# ╟─16610ace-58fc-4619-a99c-90575607c1c0
# ╟─ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
# ╟─c6270f22-51dc-44a9-80b9-ccd10dbc41ac
# ╟─4a8ce7d3-0315-4d13-9734-c47f7b87d21b
# ╟─f74312b3-54f7-4d3f-902e-3eb6494fc236
# ╟─95a7fe7f-f580-4f26-b47e-a5dac16d49f5
# ╟─719d529a-03e4-4f1b-a438-6dcfa57deec3
# ╟─16f078b5-a050-4876-9048-a06d3e2733be
# ╟─765e386b-be08-43d0-ac71-a62d0ebf23c7
# ╟─eb77b6e7-2890-447a-98c7-74b581af4dd9
# ╟─f63ea571-6452-42c1-af7e-4fb789304a2d
# ╟─f61fc2af-e411-4075-bcda-3fd761da58cb
# ╟─3e75a33e-392b-4fd0-9978-07fad6a4faf1
# ╟─82fe8645-a213-44ed-919d-18b0cbb0eeae
# ╟─0e1c20db-5322-4f38-b9e0-f9333b8b743b
# ╟─3713b423-0ef4-4685-a22d-39ae73dbb094
# ╟─f41b3285-6ff5-4f16-b936-eca01600b5b4
# ╟─04feec75-3fdd-4a32-9010-7cccf2e93d57
# ╟─2f641623-6c1c-476b-a57a-ebee39739137
# ╟─7958f21a-63af-47c8-9e7d-31a89ffa1645
# ╟─ccbfccc4-f3fd-4c86-a61e-7f6a2a0cf79b
# ╟─0eb1aa68-5c3a-46c8-9c29-c1288316d57c
# ╟─d6a1eca6-19da-411d-bcc7-cd2167678908
# ╟─ca61760e-9156-4d81-834e-e41c747e1e43
# ╟─ece3723e-57a3-4cbc-8c36-9ee8ddc7130c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
