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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Exercise 07
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

# ╔═╡ e544a5b0-a1e5-47b6-8418-5c90cdf31ce0
Markdown.parse("
> - Suppose Firm A has issued a bond with \$ $(F4_1) par value. The bond is a zero-coupon bond with maturity in $(T4_1) years. Suppose that all interest rates are $(r4)% (annually compounded). You are asked to help Firm A hedge their exposure to changes in interest rates. You can buy/sell $(T4_2)-year zero-coupon bonds in the financial market. Assume all rates are annually compounded. 
> 1. Calculate the market value and the modified duration of the bond Firm A has issued. What is the dollar loss the firm is facing when interest rates decrease by 100 basis points?
> 2. Calculate the modified duration of the $(T4_2)-year zero coupon bond.
> 3. Set up the hedging portfolio consisting of the $(T4_2)-year zero coupon bond and the bond Firm A hasissued. Then, solve for the market value of the position you need to take in the $(T4_2)-year zero coupon bond to implement a (modified) duration hedge. What is the total value of the hedging portfolio?
")


# ╔═╡ ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
md"""
## Solution
"""

# ╔═╡ 2c361b3b-ec06-433b-8260-f331a085b40d
Markdown.parse("
__Part 1__
- The price of a ``$(T4_1)``-year zero coupon bond with \$ ``$(F4_1)`` par value when interest rates are ``$(r4)`` % is

``\$P_{$(T4_1)} = \\frac{F}{(1+r)^{$(T4_1)}} = \\frac{$(F4_1)}{(1+$(r4)\\%)^{$(T4_1)}} = $(roundmult(F4_1/(1+(r4/100))^T4_1,1e-4))\$``


- This bond has a modified duration MD of
``\$MD_{$(T4_1)} = \\frac{T}{1+y} = \\frac{$(T4_1)}{1+$(r4)\\%} = $(roundmult(T4_1/(1+r4/100),1e-2))\$``

- This means that when interest rates decrease by 100 basis points, the value of Firm A's liability (in the form of the bond it has issued) increases by around ``$(roundmult(T4_1/(1+r4/100),1e-2))`` percent.

``\$\\frac{\\Delta P_{10}}{P_{$(T4_1)}}= - MD_{$(T4_1)} \\times \\Delta y = - $(roundmult(T4_1/(1+r4/100),1e-2)) \\times (-1)=$(roundmult(T4_1/(1+r4/100),1e-2))\\%\$``.

- Thus the loss in dollar terms is 
``\$\\Delta P_{10}= $(roundmult(T4_1/(1+r4/100),1e-2))\\% \\times P_{$(T4_1)}=$(roundmult(T4_1/(1+r4/100),1e-2))\\% \\times $(roundmult(F4_1/(1+(r4/100))^T4_1,1e-4)) = \\\$$(roundmult(T4_1/(1+r4/100)/100 * F4_1/(1+(r4/100))^T4_1,1e-4))\$``.

")

# ╔═╡ 1152d568-5360-401e-b264-4520c2cf09e5
Markdown.parse("
__Part 2__
- The modified duration of the $(T4_2)-year zero-coupon bond is
``\$MD_{$(T4_2)} = \\frac{T}{1+y} = \\frac{$(T4_2)}{1+$(r4)\\%} = $(roundmult(T4_2/(1+r4/100),1e-4))\$``

- Using a balance sheet to illustrate:
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond: `x` | $(T4_1)-year Bond: `$(roundmult(P4_1,1e-4))`
 ``MD_{$(T4_2)}``: `$(roundmult(MD4_2,1e-4))`| ``MD_{$(T4_1)}``: `$(roundmult(MD4_1,1e-4))`
``\\frac{\\Delta B_{$(T4_2)}}{B_{$(T4_2)}}=-MD_{$(T4_2)} \\times \\Delta y`` | ``\\frac{\\Delta B_{$(T4_1)}}{B_{$(T4_1)}}=-MD_{$(T4_1)} \\times \\Delta y``
``\\Delta B_{$(T4_2)}= B_{$(T4_2)} \\times (-MD_{$(T4_2)}) \\times \\Delta y`` | ``\\Delta B_{$(T4_1)}=B_{$(T4_1)} \\times (-MD_{$(T4_1)}) \\times \\Delta y``
``\\Delta B_{$(T4_2)}= x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y`` | ``\\Delta B_{$(T4_1)}=$(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y``
")

# ╔═╡ f0cb66f5-9b3b-4c5c-9e1b-40e2fbcf0500
Markdown.parse("
__Part 3__

The duration hedging equation is:
``\$x \\times (-$(roundmult(MD4_2,1e-4))) \\times \\Delta y \\stackrel{!}{=} $(roundmult(P4_1,1e-4)) \\times (-$(roundmult(MD4_1,1e-4))) \\times \\Delta y\$``
- This must be true for all ``\\Delta y`` which means that our position on the $(T4_2)-year zero coupon bond ``x`` must be
``\$x = $(roundmult(P4_1,1e-4)) \\times \\frac{(-$(roundmult(MD4_1,1e-4)))}{(-$(roundmult(MD4_2,1e-4)))} = $(roundmult(P4_1*MD4_1/MD4_2,1e-4))\$``
- Thus, the we take a long-position of \$ ``$(roundmult(P4_1*MD4_1/MD4_2,1e-4))`` in the $(T4_2)-year zero-coupon bond.
- This market value corresponds to a face amount of 

``\$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4)) = \\frac{F}{(1+$(r4)\\%)^$(T4_2)}\$``
``\$ F= \\\$ $(roundmult(P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2,1e-2))\$``

- To summarize, with the hedge, the market value of our assets and liabilities is
Assets            |  Liabilities
:-----------------|:--------------------
 $(T4_2)-year bond:  \$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4))  | $(T4_1)-year Bond: \$ $(roundmult(P4_1,1e-4))
 Face value: \\\$ $(roundmult(P4_1*MD4_1/MD4_2*(1+r4/100)^T4_2,1e-2)) | Face value: \\\$ $(roundmult(F4_1,1e-2))


- The market value of Firm A's portfolio (assets minus liabilities) is ``\$ \\\$ $(roundmult(P4_1*MD4_1/MD4_2,1e-4)) - \\\$ $(roundmult(P4_1,1e-4)) = \\\$ $(roundmult(P4_1*MD4_1/MD4_2-P4_1 ,1e-2))\$``
")

# ╔═╡ bccde543-ec7e-40fc-abce-ef2300ca4e99
md"""
# Question 3
"""

# ╔═╡ 0e2168f5-d66c-42f5-8593-60d54c589c14
begin
	r5 = 4.0 #percent
	F5_1 = 1000
	T5_1 = 10
	T5_2 = 2
	T5_3 = 30
	MD5_1 = T5_1/(1+r5/100)
	MD5_2 = T5_2/(1+r5/100)
    MD5_3 = T5_3/(1+r5/100)		
	P5_1 = F5_1/(1+(r5/100))^T5_1
	P5_2 = F5_1/(1+(r5/100))^T5_2
	P5_3 = F5_1/(1+(r5/100))^T5_3

	lhs5 = [MD5_2 (T5_3/(1+r5/100))
         (0.5*(T5_2^2+T5_2)/(1+r5/100)^2) (0.5*(T5_3^2+T5_3)/(1+r5/100)^2)]
 	rhs5 = [(MD5_1*P5_1), (0.5*P5_1*(T5_1^2+T5_1)/(1+r5/100)^2)]
 	sol5 = inv(lhs5)*rhs5
	display("")
end

# ╔═╡ 4f947c23-269d-403d-b1b5-623e90558483
Markdown.parse("
> - Suppose Firm A has issued a bond with \$ $(F5_1) par value. The bond is a zero-coupon bond with maturity in $(T5_1) years. Suppose that all interest rates are $(r5)% (annually compounded). You are asked to help Firm A hedge their exposure to changes in interest rates. You can buy/sell $(T5_2)-year zero-coupon bonds and $(T5_3)-year zero-coupon bonds in the financial market. Assume all rates are annually compounded. 
> 1. Calculate the modified duration, convexity, the percentage price change, and the dollar price in response to a yield change ``\\Delta y`` for all of the three bonds.
> 2. Use a balance sheet to show Firm A's hedging portfolio.
> 3. Set up the hedging portfolio consisting of the $(T5_2)-year zero coupon bond, the $(T5_3)-year zero coupon bond and the bond you have issued, and solve for the market value of the positions you need to take in the 2-year zero coupon bond to implement a (modified) duration hedge.
")

# ╔═╡ 0663b3da-e09b-4281-a516-db698acc12bf
md"""
## Solution
"""

# ╔═╡ 3e5f4259-abf5-442e-8c70-672e2af8f477
Markdown.parse("
__Part 1__

- First, calculate the duration, convexity, the percentage price change and the dollar price in response to a yield change ``\\Delta y`` for each of the three bonds.


- ``$(T5_1)``-year Zero-coupon bond (liability)
  - ``MD_{$(T5_1)}=\\frac{T}{1+y} = \\frac{$(T5_1)}{1+$(r5)\\%} = $(roundmult(T5_1/(1+r5/100),1e-4))``
  - ``\\textrm{CX}_{$(T5_1)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T5_1^2+T5_1)}{(1+$(r5)\\%)^2} = $(roundmult((T5_1^2+T5_1)/(1+r5/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T5_1)}}{P_{$(T5_1)}}= - MD_{$(T5_1)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T5_1)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T5_1)} = P_{$(T5_1)} \\times (- MD_{$(T5_1)}) \\times \\Delta y + P_{$(T5_1)} \\times \\frac{1}{2} \\times CX_{$(T5_1)} \\times \\left( \\Delta y \\right)^2``


- ``$(T5_2)``-year Zero-coupon bond (liability)
  - ``MD_{$(T5_2)}=\\frac{T}{1+y} = \\frac{$(T5_2)}{1+$(r5)\\%} = $(roundmult(T5_2/(1+r5/100),1e-4))``
  - ``\\textrm{CX}_{$(T5_2)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T5_2^2+T5_2)}{(1+$(r5)\\%)^2} = $(roundmult((T5_2^2+T5_2)/(1+r5/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T5_2)}}{P_{$(T5_2)}}= - MD_{$(T5_2)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T5_2)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T5_2)} = P_{$(T5_2)} \\times (- MD_{$(T5_2)}) \\times \\Delta y + P_{$(T5_2)} \\times \\frac{1}{2} \\times CX_{$(T5_2)} \\times \\left( \\Delta y \\right)^2``


- ``$(T5_3)``-year Zero-coupon bond (liability)
  - ``MD_{$(T5_3)}=\\frac{T}{1+y} = \\frac{$(T5_3)}{1+$(r5)\\%} = $(roundmult(T5_3/(1+r5/100),1e-4))``
  - ``\\textrm{CX}_{$(T5_3)}= \\frac{T^2+T}{(1+y)^2}=\\frac{$(T5_3^2+T5_3)}{(1+$(r5)\\%)^2} = $(roundmult((T5_3^2+T5_3)/(1+r5/100)^2,1e-4))``
  - ``\\frac{\\Delta P_{$(T5_3)}}{P_{$(T5_3)}}= - MD_{$(T5_3)} \\times \\Delta y + \\frac{1}{2} \\times CX_{$(T5_3)} \\times \\left( \\Delta y \\right)^2``
  - ``\\Delta P_{$(T5_3)} = P_{$(T5_3)} \\times (- MD_{$(T5_3)}) \\times \\Delta y + P_{$(T5_3)} \\times \\frac{1}{2} \\times CX_{$(T5_3)} \\times \\left( \\Delta y \\right)^2``

")

# ╔═╡ fd40de0d-a78d-46ae-9251-5cd869f5e7e4
Markdown.parse("
__Part 2__

Assets            |  Liabilities
:-----------------|:--------------------
 $(T5_2)-year bond: `x` | $(T5_1)-year Bond: `$(roundmult(P5_1,1e-4))`
 ``MD_{$(T5_2)}``: `$(roundmult(MD5_2,1e-4))`| ``MD_{$(T5_1)}``: `$(roundmult(MD5_1,1e-4))`
``\\textrm{CX}_{$(T5_2)}``: `$(roundmult((T5_2^2+T5_2)/(1+r5/100)^2,1e-4))` | ``\\textrm{CX}_{$(T5_1)}``: `$(roundmult((T5_1^2+T5_1)/(1+r5/100)^2,1e-4))`
``\\Delta B_{$(T5_2)}= x \\times (-$(roundmult(MD5_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T5_2^2+T5_2)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2`` | ``\\Delta B_{$(T5_1)}=$(roundmult(P5_1,1e-4)) \\times (-$(roundmult(MD5_1,1e-4))) \\times \\Delta y + $(roundmult(P5_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T5_1^2+T5_1)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2``
                       |
$(T5_3)-year bond: `z` |
``MD_{$(T5_3)}``: `$(roundmult(T5_3/(1+r5/100),1e-4))`|
``\\textrm{CX}_{$(T5_3)}`` `$(roundmult((T5_3^2+T5_3)/(1+r5/100)^2,1e-4))` |
``\\Delta B_{$(T5_3)}= z \\times (-$(roundmult(T5_3/(1+r5/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T5_3^2+T5_3)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2`` |
")

# ╔═╡ 9da797cb-3a79-44d1-bd05-f664bd4d8fff
Markdown.parse("
__Part 3__

- The hedging equation is:
``\$ \\Delta B_{$(T5_2)} + \\Delta B_{$(T5_3)} = \\Delta B_{$(T5_1)}\$``
- Using modified duration and convexity terms, this is
``\$ x \\times (-$(roundmult(MD5_2,1e-4))) \\times \\Delta y + x \\times \\frac{1}{2} ($(roundmult((T5_2^2+T5_2)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2 + z \\times (-$(roundmult(T5_3/(1+r5/100),1e-4))) \\times \\Delta y + z \\times \\frac{1}{2} ($(roundmult((T5_3^2+T5_3)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2 =$(roundmult(P5_1,1e-4)) \\times (-$(roundmult(MD5_1,1e-4))) \\times \\Delta y + $(roundmult(P5_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T5_1^2+T5_1)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2\$``


- Since this equation must hold for all ``\\Delta y`` and for all ``(\\Delta y)^2``, we can look at all terms in ``\\Delta y`` and in ``(\\Delta y)^2`` separately.
- Terms in ``\\Delta y``: **Modified Duration Equation**
  - ``\$ x \\times (-$(roundmult(MD5_2,1e-4))) \\times \\Delta y + z \\times (-$(roundmult(T5_3/(1+r5/100),1e-4))) \\times \\Delta y  =$(roundmult(P5_1,1e-4)) \\times (-$(roundmult(MD5_1,1e-4))) \\times \\Delta y \$``
- Terms in ``(\\Delta y)^2``: **Convexity Equation**
  - ``\$ x \\times \\frac{1}{2} ($(roundmult((T5_2^2+T5_2)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2 + z \\times \\frac{1}{2} ($(roundmult((T5_3^2+T5_3)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2 = $(roundmult(P5_1,1e-4)) \\times \\frac{1}{2} ($(roundmult((T5_1^2+T5_1)/(1+r5/100)^2,1e-4))) \\times (\\Delta y)^2\$``



- To solve for the positions in the bonds, first rewrite the equations by collecting all terms in `x` and `y` on the left-hand side and the constant terms on the right-hand side and by dropping the ``\\Delta y`` and ``(\\Delta y)^2`` terms.
- ``\$ $(roundmult(MD5_2,1e-4)) \\times x  + $(roundmult(T5_3/(1+r5/100),1e-4)) \\times z =$(roundmult(MD5_1*P4_1,1e-4))\$``
``\$$(roundmult(0.5*(T5_2^2+T5_2)/(1+r5/100)^2,1e-4)) \\times x  + $(roundmult(0.5*(T5_3^2+T5_3)/(1+r5/100)^2,1e-4)) \\times z = $(roundmult(0.5*P5_1*(T5_1^2+T5_1)/(1+r5/100)^2,1e-4))\$``


- The solution to this system of 2 equations in 2 unknowns is 
``\$x = $(roundmult(sol5[1],1e-4)), z = $(roundmult(sol5[2],1e-4))\$``
- Thus, we enter a position with market value of \$ $(roundmult(sol5[1],1e-4)) in the $(T5_2)-year bond, and a position with market value of \$ $(roundmult(sol5[2],1e-4)) in the $(T5_3)-year bond.
- The corresponding face values in the ``$(T5_2)``-year bond and the ``$(T5_3)``-year bonds are
\$F_{$(T5_2)} = $(roundmult(sol5[1]*(1+r5/100)^T5_2,1e-2))\$
\$F_{$(T5_3)} = $(roundmult(sol5[2]*(1+r5/100)^T5_3,1e-2))\$


- The balance sheet is now
Assets            |  Liabilities
:-----------------|:--------------------
 $(T5_2)-year bond: `$(roundmult(sol5[1],1e-4))` | $(T5_1)-year Bond: `$(roundmult(P5_1,1e-4))`
Face value ``F_{$(T5_2)}``: $(roundmult(sol5[1]*(1+r5/100)^T5_2,1e-2)) | Face value ``F_{$(T5_1)}``: $(roundmult(F5_1,1e-2))
                        |
$(T5_3)-year bond: `$(roundmult(sol5[2],1e-4))` |
Face value ``F_{$(T5_3)}``: $(roundmult(sol5[2]*(1+r5/100)^T5_3,1e-2)) | 

")

# ╔═╡ de131c40-06a2-4a84-a379-f1fae0c0d33b
md"""
# Question 4
>Suppose that we have a bond with the following terms:
> -   Face value = \$1000
> -   Coupon rate = 8% (coupons paid semi-annually)
> -   Yield = 10% (annual rate, compounded semi-annually)
> -   Time-to-maturity = 7 years
>
>1. Calculate the price of the bond.
>2. Calculate the modified duration of the bond based on annual yields. (i.e. Use the approximation formula with 10% as y, 10.1% as $y + \Delta y$, and 9.9% as $y - \Delta y$.)
>3. Calculate the modified duration of the bond based on semi-annual yields. (i.e. Use the approximation formula with 5% as y, 5.1% as $y + \Delta y$, and 4.9% as $y - \Delta y$.)
>4. Compare your answers in (b) and (c). Do their relative magnitudes make sense?
"""

# ╔═╡ a299af6e-5cb4-494e-8ea0-cb5c95c7ada2
md"""
## Solution
"""

# ╔═╡ 33d92b3f-b336-4592-ba57-8ac0af586f31
md"""
__Part 1__

$$\begin{aligned}
        40\times \frac{1}{\frac{0.1}{2}}\left[1 - \frac{1}{(1+\frac{0.1}{2})^{14}} \right]  + \frac{1000}{(1+\frac{0.1}{2})^{14}} = 901.0135906\end{aligned}$$

__Part 2__  

$$\begin{aligned}
        B(y+ \Delta y) &= 40\times \frac{1}{\frac{0.101}{2}}\left[1 - \frac{1}{(1+\frac{0.101}{2})^{14}} \right]  + \frac{1000}{(1+\frac{0.101}{2})^{14}} = 896.3957366\\
        B(y- \Delta y) &= 40\times \frac{1}{\frac{0.099}{2}}\left[1 - \frac{1}{(1+\frac{0.099}{2})^{14}} \right]  + \frac{1000}{(1+\frac{0.099}{2})^{14}} = 905.6615702\end{aligned}$$

$$\begin{aligned}
        MD\approx -\frac{896.3957366 - 905.6615702}{2\times 0.001}\times \frac{1}{901.0135906} = 5.1419\end{aligned}$$

__Part 3__  

$$\begin{aligned}
        B(y + \Delta y) &= 40 \times \frac{1}{0.051}\left[1 - \frac{1}{1.051^{14}}\right] + \frac{1000}{1.051^{14}} = 891.80779\\
        B(y - \Delta y) &= 40 \times \frac{1}{0.049}\left[1 - \frac{1}{1.049^{14}}\right] + \frac{1000}{1.049^{14}} = 910.339895\end{aligned}$$

$$\begin{aligned}
        MD \approx -\frac{891.80779 - 910.339895}{2\times 0.001}\times \frac{1}{901.0135906} = 10.2840\end{aligned}$$

__Part 4__

The modified duration using semi-annual yields (as in part 3) is twice as large as the modified duration using annual yields (as in part 2). This makes sense as an increase in the semi-annual yield of one percentage point (i.e. 5% to 6%) is         equivalent to an increase in the annual yield of two percentage points (i.e. 10% to 12%). Thus, a one percentage point increase in the semi-annual yield should have twice the effect of a one percentage point increase in the annual yield. Note that

$$\begin{aligned}5.1419 \times 2\% \approx 10.2840 \times 1\%\end{aligned}$$

"""

# ╔═╡ cdb2724b-9fa0-4dfe-b9c7-2406b2d1dcec
md"""
# Question 5

>Using the zero-coupon yield curve shown below, calculate the modified duration of portfolio A. Note that the yield curve is for annual yields that are semi-annually compounded.
>
>
>| T 	| 0.5 	| 1.0 	| 1.5 	| 2.0 	| 2.5 	| 3.0 	| 3.5 	| 4.0 	| 4.5 	| 5.0 	| 5.5 	| 6.0 	| 6.5 	| 7.0 	|
>|---	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|-----	|
>| y 	|  0.0649   	|  0.0671   	| 0.0684   	| 0.0688   	| 0.0683   	| 0.0676   	| 0.0667   	| 0.0676   	| 0.0657   	| 0.0645   	| 0.0631   	| 0.0615  	| 0.0594  	| 0.0567  	|
>
> __Portfolio A__
>    -   40% invested in 4-year bonds, 5% coupon rate, semi-annual coupons.
>    -   25% invested in 7-year bonds, 2.5% coupon rate, semi-annual coupons.
>    -   35% invested in 1-year zero coupon bonds.
>
> You can use the approximation formulas given in class:
>
>$$\begin{aligned}
>    MD & \approx -\frac{B(y + \Delta y) - B(y - \Delta y)}{2\times \Delta y}\times\frac{1}{B(y)} \\
>    C & \approx \frac{B(y + \Delta y) + B(y - \Delta y) - 2\times B(y)}{(\Delta y)^2}\times\frac{1}{B(y)} \\\end{aligned}$$
>
> 1.  Calculate the modified duration (based on annual yields) for each of the three bonds and then calculate the portfolio modified duration.
>     
> 2.  What is the approximate percentage change in the value of the portfolio if the term structure of (annual) interest rates increases by one percentage point (i.e. the whole zero-coupon yield curve shifts up)? Consider using Modified Duration only and then Modified Duration with Convexity. What is the actual percentage change in portfolio value?
"""

# ╔═╡ 25c2d01c-f648-48a7-b2cb-71bc9750d8d5
md"""
## Solution
"""

# ╔═╡ 5aef0131-bb5b-4acb-b267-acd2f02a55e4
md"""
__Part 1__

*4-yr bond* $$\begin{aligned}
        B(y) &= \frac{2.5}{1 + \frac{0.0649}{2}} + \frac{2.5}{\left(1+\frac{0.0671}{2}\right)^2} + ... + \frac{102.5}{\left(1+\frac{0.0667}{2}\right)^8} = 94.18094\\
        B(y + \Delta y) &= \frac{2.5}{1 + \frac{0.0649 + 0.001}{2}} + \frac{2.5}{\left(1+\frac{0.0671+0.001}{2}\right)^2} + ... + \frac{102.5}{\left(1+\frac{0.0667+0.001}{2}\right)^8} = 93.84779\\
        B(y - \Delta y) &= \frac{2.5}{1 + \frac{0.0649 - 0.001}{2}} + \frac{2.5}{\left(1+\frac{0.0671-0.001}{2}\right)^2} + ... + \frac{102.5}{\left(1+\frac{0.0667-0.001}{2}\right)^8} = 94.5155\\\end{aligned}$$

Using the approximation formulas above and plugging in for $B(y)$, $B(y + \Delta y)$, and $B(y - \Delta y)$


$$\begin{aligned}
MD & \approx 3.5448\\
C &\approx 14.9794\\
\end{aligned}$$


We can make similar calculations for the other two bonds, finding

Bond   |    $B(y)$  | $B(y + \Delta y)$ |  $B(y - \Delta y)$  |     MD   |   C |
------ | ---------- | ------------------| ------------------- | -------- | --------|
4yr    |  94.18094  |        93.84779   |          94.5155    | 3.5448   | 14.9794 |
7yr    |  81.54601  |        81.04008   |         82.05553    | 6.2262   | 44.0858 |
1yr    |  93.61318  |        93.52268   |         93.70382    | 0.9675   |  1.4042 |


- Portfolio Modified Duration = 0.4(3.5448) + 0.25(6.2262) + 0.35(0.9675) = 3.3131\
- Portfolio Convexity = 0.4(14.9794) + 0.25(44.0858) + 0.35(1.4042) = 17.5047
"""

# ╔═╡ 1e3d65aa-142b-46f1-a6f0-a491f134261b
md"""
__Part 2__

- Modified Duration Only: 
$$\begin{aligned}
        \frac{\Delta B}{B} \approx -MD \times \Delta y = -3.3131 \times 0.01 = -3.3131\%
\end{aligned}$$

- Modified Duration & Convexity: 
$$\begin{aligned}
        \frac{\Delta B}{B} \approx -MD \times \Delta y + \frac{1}{2}C(\Delta y)^2 = -3.3131 \times 0.01 + \frac{1}{2}(17.5047)(0.01)^2 = -3.2256\%
\end{aligned}$$

- Actual Change:\
1. First, calculate the prices of each of the three bonds if all yields increase by 1 percentage point: 
$$\begin{aligned}
        B(y + 1\%, 4yr) &= \frac{2.5}{1 + \frac{0.0649+0.01}{2}} + \frac{2.5}{\left(1+\frac{0.0671+0.01}{2}\right)^2} + ... + \frac{102.5}{\left(1+\frac{0.0667+0.01}{2}\right)^8}\\
        &= 90.91182\\
        B(y + 1\%, 7yr) &= 76.64406\\
        B(y + 1\%, 1yr) &= 92.71397
\end{aligned}$$

2. We can now calculate the return to each of the bonds:
$$\begin{aligned}
        \text{\% change for 4yr bond} &= \frac{90.91182}{94.18094} - 1 = -3.471\%\\
        \text{\% change for 7yr bond} &= \frac{76.64406}{81.54601} - 1 = -6.011\%\\
        \text{\% change for 1yr bond} &= \frac{92.71397}{93.61318} - 1 = -0.9606\%
\end{aligned}$$

3. Finally, the portfolio return is 
$$\begin{aligned}
0.4(-3.471\%) + 0.25(-6.011\%) + 0.35(-0.9606\%) = -3.23\%
\end{aligned}$$
This is very close to the Modified Duration & Convexity approximation.

"""

# ╔═╡ c1a4b31e-dd81-41bf-badd-4c739962e25f
md"""
# Question 6
"""

# ╔═╡ ceed05db-b1d6-4136-b73d-8214f32b51a4
md"""
> In July 1993, Disney issued a bond with \$300,000,000 in face value.
> -   The coupon rate was 7.55%, paid semi-annually.
> -   The maturity was July 15, 2093. (100 years)
> -   The yield at issuance was 7.55%, so the bond was issued at par.
> -   Assume \$100 par value throughout.
>
> 1. Approximate the modified duration (based on semi-annual yields) using the approximation formula: 
>
>$$\begin{aligned}
>        MD \approx -\frac{B(y+\Delta y) - B(y - \Delta y)}{2\Delta y}\times\frac{1}{B(y)}
>\end{aligned}$$
>
>For $\Delta y$, use 0.001 (semi-annual yields of 3.875% and 3.675%).
>
> 2. Approximate the convexity using: 
>
>$$\begin{aligned}
>        \frac{B(y+\Delta y) + B(y - \Delta y) - 2 B(y)}{(\Delta y)^2}\times\frac{1}{B(y)}
>\end{aligned}$$
>
> 3. Calculate the prices of the Sleeping Beauty bonds if the annual yield (semi-annually compounded) is (i) 6.55%, (ii) 8.55%. It is recommended that you use the annuity formula to calculate the value of the coupons and then add back the present value of the par value.
> 
> 4. Given how sensitive the Sleeping Beauty bonds are to changes in interest rates, we want to hedge against interest rate movements. Suppose you own \$100 worth of Sleeping Beauty bonds and there are two other bonds that we can use to hedge interest rate shifts:
>
> - 2-year zero coupon bond with a 5% yield (semi-annually compounded, so a 2.5% semi-annual yield)
> - 10-year zero coupon bond with a 6% yield (semi-annually compounded, so a 3% semi-annual yield)
> - Calculate the modified duration and convexity of the two zero coupon bonds. Calculate these in terms of half-years.
>
> 5.  Calculate how much you would short in the 2-year and 10-year bonds to hedge the interest rate sensitivity of the Sleeping Beauty bond. What is the overall value of your portfolio? What is the face value of your positions in the 2-year and 10-year bonds?
>
> 6. Calculate the market value of your portfolio if all (annual) yields increased by three percentage points.



"""

# ╔═╡ 6101d65d-d5e2-4303-b3cf-79340095f573
md"""
## Solution
"""

# ╔═╡ 22fd7f62-6d2f-457b-8ae5-ff4ed9fc354d
md"""
__Part 1__

$$\begin{aligned}
        B(y = 3.775\%) &= 3.775 \times \frac{1}{0.03775}\left[1 - \frac{1}{1.03775^{200}}\right] + \frac{100}{1.03775^{200}} = 100\\
        B(y = 3.875\%) &= 3.775 \times \frac{1}{0.03875}\left[1 - \frac{1}{1.03875^{200}}\right] + \frac{100}{1.03875^{200}} = 97.42064167\\
        B(y = 3.675\%) &= 3.775 \times \frac{1}{0.03675}\left[1 - \frac{1}{1.03675^{200}}\right] + \frac{100}{1.03675^{200}} = 102.7190935
\end{aligned}$$

$$\begin{aligned}
        MD \approx -\frac{97.42064167 - 102.7190935}{2\times 0.001}\times \frac{1}{100} = 26.49
\end{aligned}$$


__Part 2__

$$\begin{aligned}
        C \approx \frac{97.42064167 + 102.7190935 - 2 \times 100}{0.001^2} \times \frac{1}{100} = 1397.3517
\end{aligned}$$


__Part 3__

$$\begin{aligned}
        B(y = 6.55\%\text{ annually}) &= 3.775 \times \frac{1}{0.03275}\left[1-\frac{1}{1.03275^{200}}\right] +  \frac{100}{1.03275^{200}}= 115.24\\
        B(y = 8.55\%\text{ annually}) &= 3.775 \times \frac{1}{0.04275}\left[1-\frac{1}{1.04275^{200}}\right] + \frac{100}{1.04275^{200}} = 88.31
\end{aligned}$$


__Part 4__

- Recall that for zero-coupon bonds, 
$$\begin{aligned}
        MD &= \frac{T}{1+y}\\
        C &= \frac{T^2 + T}{(1+y)^2}
\end{aligned}$$ 
  - Note: Since we are using half-year yields and T is in half-years, we can use these formulas.

$$\begin{aligned}
        MD_2 &= \frac{4}{1.025} = 3.9024\\
        MD_{10} &= \frac{20}{1.03} = 19.4175\\
        C_2 &= \frac{4^2 + 4}{1.025^2} = 19.0363\\
        C_{10} &= \frac{20^2 + 20}{1.03^2} = 395.8903
\end{aligned}$$

- Set up a balance sheet to illustrate the hedging portfolio.

| Long | Short | |
|----------------------------------------------------------------------------------------|--------------------|---------------------|
| \$100 in Disney bonds                                                                  | \$x in 2-year zero | \$z in 10-year zero |
| $MD = 26.4923$                                                                         | $MD_2 = 3.9024$    | $MD_{10} = 19.4175$ |
| $C = 1397.3517$                                                                        | $C_2 = 19.0363$    | $C_{10} = 395.8903$ |
| | If yields increase by $\Delta y$ | |
| $\frac{\Delta B_{D}}{B_{D}} \approx -MD_{D} \Delta y + \frac{1}{2} C_{D} (\Delta y)^2$ | $\frac{\Delta B_{2}}{B_{2}} \approx -MD_{2} \Delta y + \frac{1}{2} C_{2} (\Delta y)^2$ | $\frac{\Delta B_{10}}{B_{10}} \approx -MD_{10} \Delta y + \frac{1}{2} C_{10} (\Delta y)^2$                   |

- Setting up the hedging equations.

$\frac{\Delta B_{D}}{B_{D}} \approx -MD_{D} \Delta y + \frac{1}{2} C_{D} (\Delta y)^2$   $\frac{\Delta B_{2}}{B_{2}} \approx -MD_{2} \Delta y + \frac{1}{2} C_{2} (\Delta y)^2$   $\frac{\Delta B_{10}}{B_{D}} \approx -MD_{10} \Delta y + \frac{1}{2} C_{10} (\Delta y)^2$

$$\begin{aligned}
        \Delta B_D &\approx 100\left[-26.4923 \times \Delta y + \frac{1}{2}(1397.3517)\left(\Delta y\right)^2\right]\\
        \Delta B_2 &\approx x\left[-3.9024 \times \Delta y + \frac{1}{2}(19.0363)\left(\Delta y\right)^2\right]\\
        \Delta B_{10} &\approx z\left[-19.4175 \times \Delta y + \frac{1}{2}(395.8903)\left(\Delta y\right)^2\right]\\
\end{aligned}$$

- Modified Duration Equation ($\Delta y$ part) 
$$\begin{aligned}
        100(-26.4923) = x(-3.9024) + z(-19.4175)
\end{aligned}$$

- Convexity Equation ($(\Delta y)^2$ part) 
$$\begin{aligned}
100\left(\frac{1}{2}\right)(1397.3517) = x\left(\frac{1}{2}\right)(19.0363) + z\left(\frac{1}{2}\right)(395.8903)
\end{aligned}$$

Solving for x and z:\
  - x = -1416.85 (so we are actually long the bond, not short)\
  - z = 421.0931 (still short)

- Value of the portfolio = 100 + 1416.85 - 421.0931 = 1095.753

- Face value of 2yr: $1416.85(1.025)^4 = 1563.93$\
- Face value of 10yr: $421.0931(1.03)^{20} = 760.5409$


__Part 5__

- Yield on the Disney bond is now 10.55%
- Yield on the 2yr bond is now 8%
- Yield on the 10yr bond is now 9%

$$\begin{aligned}
        B_D &= 3.775 \times \frac{1}{0.05275} \left[1 - \frac{1}{1.05275^{200}}\right] + \frac{100}{1.05275^{200}} = 71.565\\
        B_2 &= \frac{1563.93}{1.04^4} = 1336.86\\
        B_{10} &= \frac{760.5409}{1.045^{20}} = 315.3529
\end{aligned}$$

- Portfolio value = 71.565 + 1336.86 - 315.3529 = 1093.07

  - Note how the portfolio value has changed very little.

"""

# ╔═╡ 8ecefc50-ff60-4646-a4d8-491801f75085
md"""
# Question 7

"""

# ╔═╡ e9fd30bf-5a05-42f6-8071-66a1e0de43c0
md"""
> Suppose that you are managing a pension fund that has liabilities of \$200mm per year for the next 10 years and \$100mm per year for each year after that. Suppose also that all discount rates are 4% per year (annually compounded).
>
> 1. What is the value of the pension liability?
> 2. What is the modified duration of the pension liability?
> 3. Suppose that the pension is fully funded. Specifically, suppose that the pension has exactly the same amount of cash as the value of the pension liability. How much of a 2yr and a 10yr zero coupon bond should you buy (using the cash available to the pension fund) so that the assets of the pension have roughly the same sensitivity to interest rates as the pension liability?


"""

# ╔═╡ fd955e76-17f3-4359-8c3c-432555cd203a
md"""
## Solution
"""

# ╔═╡ 2f86100d-a845-4001-8443-7d7f856b3084
md"""
__Part 1__

We can break the liability into two pieces:
-   A 10-year annuity of \$100mm
-   A perpetuity of \$100mm

$$\begin{aligned}
        100\times \frac{1}{0.04}\left[1-\frac{1}{1.04^{10}}\right] + \frac{100}{0.04} = 3311.089578
\end{aligned}$$

__Part 2__

Value of liability at a discount rate of 4.1% 

$$\begin{aligned}
        100\times \frac{1}{0.041}\left[1-\frac{1}{1.041^{10}}\right] + \frac{100}{0.041} = 3246.091267
\end{aligned}$$

Value of liability at a discount rate of 3.9% 
$$\begin{aligned}
        100\times \frac{1}{0.039}\left[1-\frac{1}{1.039^{10}}\right] + \frac{100}{0.039} = 3379.244965
\end{aligned}$$

$$\begin{aligned}
        MD \approx -\frac{3246.091267 - 3379.244965}{2\times 0.001}\times\frac{1}{3311.089578} = 20.1072
\end{aligned}$$


__Part 3__

| Assets                         |                                 | Liabilities                     |
|--------------------------------|---------------------------------|---------------|
| 2yr                            | 10yr                            | Pension        |
| \$x                            | \$z                             | \$3311.089578  |
| $MD = \frac{2}{1.04} = 1.9231$ | $MD = \frac{10}{1.04} = 9.6154$ | $MD = 20.1072$ |

- MD Equation 

$$\begin{aligned}
        1.9231x + 9.6154 z = 20.1072 \times (3311.085578)
\end{aligned}$$ 

- Assets= Liabilities Equation 

$$\begin{aligned}
        x + z = 3311.089578
\end{aligned}$$

- Solving for $x$ and $z$.
$$x = -4516.13$$
$$z = 7827.22$$

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
# ╟─f31d870c-27b4-40d0-8327-b80bbb5581eb
# ╟─e544a5b0-a1e5-47b6-8418-5c90cdf31ce0
# ╟─ed20508e-bfe2-4247-8a8a-cbf1860bfaa1
# ╟─2c361b3b-ec06-433b-8260-f331a085b40d
# ╟─1152d568-5360-401e-b264-4520c2cf09e5
# ╟─f0cb66f5-9b3b-4c5c-9e1b-40e2fbcf0500
# ╟─bccde543-ec7e-40fc-abce-ef2300ca4e99
# ╟─4f947c23-269d-403d-b1b5-623e90558483
# ╟─0e2168f5-d66c-42f5-8593-60d54c589c14
# ╟─0663b3da-e09b-4281-a516-db698acc12bf
# ╟─3e5f4259-abf5-442e-8c70-672e2af8f477
# ╟─fd40de0d-a78d-46ae-9251-5cd869f5e7e4
# ╟─9da797cb-3a79-44d1-bd05-f664bd4d8fff
# ╟─de131c40-06a2-4a84-a379-f1fae0c0d33b
# ╟─a299af6e-5cb4-494e-8ea0-cb5c95c7ada2
# ╟─33d92b3f-b336-4592-ba57-8ac0af586f31
# ╟─cdb2724b-9fa0-4dfe-b9c7-2406b2d1dcec
# ╟─25c2d01c-f648-48a7-b2cb-71bc9750d8d5
# ╟─5aef0131-bb5b-4acb-b267-acd2f02a55e4
# ╟─1e3d65aa-142b-46f1-a6f0-a491f134261b
# ╟─c1a4b31e-dd81-41bf-badd-4c739962e25f
# ╟─ceed05db-b1d6-4136-b73d-8214f32b51a4
# ╟─6101d65d-d5e2-4303-b3cf-79340095f573
# ╟─22fd7f62-6d2f-457b-8ae5-ff4ed9fc354d
# ╟─8ecefc50-ff60-4646-a4d8-491801f75085
# ╟─e9fd30bf-5a05-42f6-8071-66a1e0de43c0
# ╟─fd955e76-17f3-4359-8c3c-432555cd203a
# ╟─2f86100d-a845-4001-8443-7d7f856b3084
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
