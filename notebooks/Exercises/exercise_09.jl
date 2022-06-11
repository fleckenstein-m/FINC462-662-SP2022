### A Pluto.jl notebook ###
# v0.19.4

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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Exercise 09
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

# ╔═╡ c3f1cfaf-fcd4-4829-bcf9-7cadde289ec8
md"""
Suppose you are given the following term structure of interest rates (zero-coupon yields). All interest rates are annual, but semi-annually compounded.

| t           | 0.5   | 1       | 1.5    | 2      |  2.5    | 3     |
|:------------|:------|:--------|:-------|:-------|:--------|:------|
|  Spot rate  | 0.02  | 0.025   | 0.03   | 0.03   | 0.035   | 0.04  |

"""

# ╔═╡ fb21e25a-85ae-447f-8f0c-ff3336794ba9
md"""
__1.1__ What is the value of a three-year floating rate bond that pays coupons semi-annually based on the prevailing half-year spot rate at the start of each period? Suppose that the bond has a face value of \$100.
"""

# ╔═╡ 8a8e6644-2940-41b5-8fee-9d897588226f
md"""
!!! correct

	We are at an interest reset date before any interest rates have
    changed. Thus, the value of the floating rate bond is its face
    value, 100.
"""

# ╔═╡ ec2ab381-d098-4949-8704-cb0f16db8121
md"""
__1.2__  What is the value of a three-year zero coupon bond with a face value of \$100?

"""

# ╔═╡ 532d790e-5397-4911-89ce-cad0589c1737
md"""
!!! correct

-   $$P = \frac{100}{\left(1+\frac{4\%}{2}\right)^{2\times 3}} = 88.7971$$

"""

# ╔═╡ c1f9a1b2-8a5b-4d24-87e5-48a4e0f43e1d
md"""
__1.3__ What is the value of a security that has three years to maturity and at each six-month horizon pays $100\times\frac{r}{2}$, where $r$ is the half-year spot rate at the start of the six month period? 
- For example, the first payment is $100\times\frac{0.02}{2} = 1$.
"""

# ╔═╡ 197824b0-1227-4e2b-93c2-88bfd1cacc24
md"""
!!! correct
    The security described is the set of coupon payments to the
    floating rate bond in (a). The value is 100 - 88.7971 = 11.2029.
"""

# ╔═╡ 0d2fa9e4-421c-4fe2-ba95-828bef51a94e
md"""
# Question 2
"""

# ╔═╡ 57cd074a-c21d-44e4-bb38-14a19ad4ae8e
md"""
__2.1__ Suppose that it is January 2, 2008. Use the LIBOR curve below. All interest rates are annual, but semi-annually compounded. You enter a 1-year fixed-for-floating interest rate swap with quarterly payments and a \$100mm notional. What is the fair one-year swap rate?

| t     | 1/12   | 2/12   | 3/12  | 4/12  | 5/12 |  6/12 | 7/12  | 8/12   | 9/12  | 10/12  | 11/12   | 12/12  |
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----  |:-----|
| t     | 0.0457  | 0.0464   | 0.0468  | 0.0465  | 0.0461 | 0.0457 | 0.045  | 0.0442   | 0.0435  | 0.0429  | 0.0424   | 0.0419  |

"""

# ╔═╡ 7e238731-6e10-4af9-abad-8e59f744dc96
md"""
!!! correct

	- Recall that we can add a cash flow of the principal amount to the end of both the fixed and floating side without changing anything.

	- The value of the floating rate bond is 100. 
	- The value of the fixed rate bond is: 

	$$\begin{aligned}
	        \frac{C}{\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}} + \frac{C}{\left(1+\frac{0.0457}{2}\right)^{2\times 0.50}} + \frac{C}{\left(1+\frac{0.0435}{2}\right)^{2\times 0.75}} + \frac{C + 100}{\left(1+\frac{0.0419}{2}\right)^{2\times 1.00}}
	\end{aligned}$$

	- Note that the first payment is in one quarter. Since the discount rates are semi-annually compounded, that is in a half period (one quarter is one half of a half year). Thus, the first cashflow is discounted by
	
	$\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}$.
	
	- Set the fixed and floating bonds equal: 
	
	$$\begin{aligned}
	        \frac{C}{\left(1+\frac{0.0468}{2}\right)^{2\times 0.25}} + \frac{C}{\left(1+\frac{0.0457}{2}\right)^{2\times 0.50}} + \frac{C}{\left(1+\frac{0.0435}{2}\right)^{2\times 0.75}} + \frac{C + 100}{\left(1+\frac{0.0419}{2}\right)^{2\times 1.00}} = 100
	\end{aligned}$$
	
	$$\rightarrow C = 1.0425$$
	
	- Since the cash flow is $C=\frac{f}{4}\times100$, we have $f=4\times C / 100=0.0417$.
	
	- The swap rate is $f=4.17\%$.

"""

# ╔═╡ 334c5066-48c5-467d-9c49-4c450a276cb6
md"""
__2.2__ What is the value of the interest rate swap at inception?"""

# ╔═╡ 5c7ce965-ab98-46d4-a87a-0d4dfd1fa773
md"""
!!! correct
	The value of an interest rate swap at inception is 0.
"""

# ╔═╡ 520998e4-c8c2-43bf-b109-41edf49d1fad
md"""
__2.3__ Suppose that it is now Feb 1, 2008. Use the LIBOR curve for that date given below. What is the value of the interest rate swap? 

| t     | 1/12   | 2/12   | 3/12  | 4/12  | 5/12 |  6/12 | 7/12  | 8/12   | 9/12  | 10/12  | 11/12   | 12/12  |
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----  |:-----|
| t     | 0.0314  | 0.0311   | 0.0310  | 0.0307  | 0.0305 | 0.0302 | 0.0297  | 0.0292   | 0.0288  | 0.0285  | 0.0283   | 0.0282  |

- To do this, calculate the present value of the fixed and floating legs separately. Then determine the value of paying fixed and receiving floating.
"""

# ╔═╡ e1a57ffc-3e0d-412e-a863-83be5c83d966
md"""
!!! correct
	- Follow the same methodology as before, but with some minor changes. The floating rate bond is no longer worth \$100 because we are not at an interest reset date. 
	- On Jan 2, 2008, the first coupon payment was locked in at $\frac{4.68}{4}$. 
	- We also know that on the next interest reset date (in 2 months), the bond        will be worth \$100 after the coupon is paid. 
	- Thus, the value of the floating rate bond is: 
	$$\begin{aligned}
	        \frac{\frac{4.68}{4} + 100}{\left(1+\frac{0.0311}{2}\right)^{2\times \frac{2}{12}}} = 100.65
	\end{aligned}$$
	
	- The value of the fixed leg is: 
	$$\begin{aligned}
	        \frac{1.0425}{\left(1+\frac{0.0311}{2}\right)^{2\times \frac{2}{12}}} + \frac{1.0425}{\left(1+\frac{0.0305}{2}\right)^{2\times \frac{5}{12}}} \frac{1.0425}{\left(1+\frac{0.0292}{2}\right)^{2\times \frac{8}{12}}} + \frac{1.0425+100}{\left(1+\frac{0.0283}{2}\right)^{2\times \frac{11}{12}}} = 101.56
	\end{aligned}$$
	
	- The value of the fixed-for-floating interest rate swap is 100.65 - 101.56 = -0.91.
"""

# ╔═╡ ce159537-5bd7-4bee-8767-b5b9f95f2caa
md"""
# Question 3
"""

# ╔═╡ 094611b7-be02-4df0-9df6-e7deaa09b3b7
md"""
__3.1__ Suppose that you are given the following term structure of interest rates (zero-coupon yields). All interest rates are annual, but semi-annually compounded.
What is the fair fixed rate in an interest rate swap where payments are made semi-annually?

| t           | 0.5    | 1      | 1.5     | 2     | 2.5    | 3      |
|:------------|:-------|:-------|:--------|:------|:-------|:-------|
| Spot rate   | 0.02   | 0.025  | 0.03    | 0.03  | 0.035  | 0.04   |

"""

# ╔═╡ 60002e52-eb89-4ce1-8e08-b570d0281715
md"""
!!! correct
    
	- Use the methodology where we add a principal payment at the end of both the fixed side and the floating side. 
	- Thus, the interest rate swap becomes a swap of a fixed rate bond and a floating rate bond.
	
	- Value of fixed rate bond paying semi-annual coupons of $C$ per period: 
	
	$$\begin{aligned}
	        \frac{C}{1.01^{2\times 0.5}} + \frac{C}{1.0125^{2\times 1}} + \frac{C}{1.015^{2\times 1.5}} + \frac{C}{1.015^{2\times 2.0}} + \frac{C}{1.0175^{2\times 2.5}} + \frac{C}{1.02^{2\times 3.0}} + \frac{100}{1.02^{2\times 3.0}}
	\end{aligned}$$
	
	- Value of the floating rate bond in this case: 
	$$\begin{aligned}        100
	\end{aligned}$$
	
	- Set fixed and floating equal: 
	$$\begin{aligned}
	        \frac{C}{1.01^{2\times 0.5}} + \frac{C}{1.0125^{2\times 1.0}} + \frac{C}{1.015^{2\times 1.5}} + \frac{C}{1.015^{2\times 2.0}} + \frac{C}{1.0175^{2\times 2.5}} + \frac{C}{1.02^{2\times 3.0}} + \frac{100}{1.02^{2\times 3.0}}=100
	\end{aligned}$$
	
	- Solving, $C = 1.9762$.
	- Since, $C=\frac{f}{2}\times 100$, we get $f = 2\times C/100=2\times 1.9762/100=0.0395$. 
	- Thus, the fair fixed rate is 3.95% per year.
	

"""

# ╔═╡ 47c9fb2f-8109-4d47-bca2-fe9489ef6b28
md"""
__3.2__ Suppose that you enter into a floating-for-fixed interest rate swap at the rate determined in 3.1. The notional is 100. Suppose that just a few minutes after you enter into this contract, the whole term structure of interest rates increases by one percentage point. What is the value of your interest rate swap position?
"""

# ╔═╡ 0b1c5be7-b95d-4bdb-9756-984e9c93b01a
md"""
!!! correct

	- New value of the fixed rate bond: 
	$$\begin{aligned}
	        \frac{1.9762}{1.015^{2\times 0.5}} + \frac{1.9762}{1.0175^{2\times 1.0}} + \frac{1.9762}{1.02^{2\times 1.5}} + \frac{1.9762}{1.02^{2\times 2.0}} + \frac{1.9762}{1.0225^{2\times 2.5}} + \frac{1.9762}{1.025^{2\times 3.0}} + \frac{100}{1.025^{2\times 3.0}}=97.2242
	\end{aligned}$$
	
	- New value of the floating rate bond: 
	$$\begin{aligned}
	        \frac{101}{1.015^{2\times 0.5}} = 99.5074
	\end{aligned}$$
	
	- Value of floating-for-fixed interest rate swap:
	$$\begin{aligned}
	        \text{Value of fixed coupon bond} - \text{Value of floating rate bond} &= 97.2242 - 99.5074\\
	        &= -2.28
	\end{aligned}$$
"""

# ╔═╡ 84e77f5c-2581-4f49-9a98-87061bc03cce
md"""
__3.3__  Did you make or lose money? What is the intuition behind this?
"""

# ╔═╡ 76b7b437-d1eb-4dc4-b058-cfbea4de2a98
md"""
!!! correct 

	- Lost money. When interest rates go up, bond values go down.
	- However, since fixed coupon bonds are typically more sensitive to interest rates than floating rate bonds, the fixed coupon bond went down in value more. 
	- In a floating-for-fixed swap, we are paying floating and receiving fixed. 
	- The value of what we are paying went down, but the value of what we are receiving went down more. 
	- Thus, we lost money. (Conversely, the person on the other side of the trade made money.)
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

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

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
# ╟─d160a115-56ed-4598-998e-255b82ec37f9
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─19b58a85-e443-4f5b-a93a-8d5684f9a17a
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─7ad75350-14a4-47ee-8c6b-6a2eac09ebb1
# ╟─c3f1cfaf-fcd4-4829-bcf9-7cadde289ec8
# ╟─fb21e25a-85ae-447f-8f0c-ff3336794ba9
# ╟─8a8e6644-2940-41b5-8fee-9d897588226f
# ╟─ec2ab381-d098-4949-8704-cb0f16db8121
# ╟─532d790e-5397-4911-89ce-cad0589c1737
# ╟─c1f9a1b2-8a5b-4d24-87e5-48a4e0f43e1d
# ╟─197824b0-1227-4e2b-93c2-88bfd1cacc24
# ╟─0d2fa9e4-421c-4fe2-ba95-828bef51a94e
# ╟─57cd074a-c21d-44e4-bb38-14a19ad4ae8e
# ╟─7e238731-6e10-4af9-abad-8e59f744dc96
# ╟─334c5066-48c5-467d-9c49-4c450a276cb6
# ╟─5c7ce965-ab98-46d4-a87a-0d4dfd1fa773
# ╟─520998e4-c8c2-43bf-b109-41edf49d1fad
# ╟─e1a57ffc-3e0d-412e-a863-83be5c83d966
# ╟─ce159537-5bd7-4bee-8767-b5b9f95f2caa
# ╟─094611b7-be02-4df0-9df6-e7deaa09b3b7
# ╟─60002e52-eb89-4ce1-8e08-b570d0281715
# ╟─47c9fb2f-8109-4d47-bca2-fe9489ef6b28
# ╟─0b1c5be7-b95d-4bdb-9756-984e9c93b01a
# ╟─84e77f5c-2581-4f49-9a98-87061bc03cce
# ╟─76b7b437-d1eb-4dc4-b058-cfbea4de2a98
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
