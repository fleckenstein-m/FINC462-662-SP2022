### A Pluto.jl notebook ###
# v0.17.1

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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Price-Quoting Conventions in the U.S. Treasury Market</b> <p>
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
        <input type="checkbox" value="">Understand how prices for Treasury securities are quoted in secondary markets.<br><br>
	    <input type="checkbox" value="">Know how to calculate accrued interest.<br><br>
	</fieldset>      
	"""
end

# ╔═╡ 93db6880-429c-4b9c-a807-eba600e03df1
md"""
# Price Quotes of for Treasury Notes/Bonds
"""

# ╔═╡ 1fa89db5-8185-4c32-81ad-4cc7e4ec44c4
md"""
## Example: 5-year Treasury Note in Bloomberg
- On the Bloomberg Terminal type `91282CCZ2` and click on the security in the search result. 
- Next, type `DES` and `Enter`.
"""

# ╔═╡ aac27a3c-e90a-437f-a563-f81d41c8d3f7
LocalResource("./TreasuryNoteDescrExampleBloomberg.png",:width => 1200) 

# ╔═╡ 39af52c6-ddb1-41ec-be5c-c0e31a2693bb
md"""
## Price Quotes for 5-year Treasury Note
- On the Bloomberg Terminal click on `ALLQ` under _Quick Links_
"""

# ╔═╡ 6561b7a0-368c-43c6-ada9-36b83dc4a749
LocalResource("./TreasuryNotePriceQuoteBloomberg.png",:width => 1200) 

# ╔═╡ 15cb9e60-6e54-4f0e-abb2-9249bdc49677
md"""
>- How to get there on the Bloomberg terminal?
>  - On the keyboard type `T Govt`
>  - Click on `United States Treasury Note/Bond (Multiple Matches) Govt`
>  - On the next page, click on one of the Treasury notes/bonds.
>  - Next, type `DES` on the keyboard and press enter.
>  - The page you now see is the `Description` page for the Treasury you selected.
>  - Next, type `ALLQ` and press enter.
>  - This will display a page with quoted prices for the Treasury note/bond you selected.
"""

# ╔═╡ 30ce6f74-1d7e-465d-abf1-245881fec53b
md"""
## Price Quotes for Treasury Coupon Securities
- Expressed as a percent of face value (often called “points”) and numbers after the hyphens denote 32nds (often called “ticks”).
"""

# ╔═╡ 5bfbddd7-c014-45c1-871d-ae41d5c02c82
md"""
##
"""

# ╔═╡ 4ad79093-2e8b-4fd7-bc1d-87388947ffde
md"""
- Points: $(@bind p1 Slider(90:1:120, default=98, show_value=true))
- 32nd: $(@bind p2 Slider(10:1:31, default=26, show_value=true))
"""

# ╔═╡ 395335f3-3f6c-4fbc-bf0b-9a238c8b6864
Markdown.parse("
**Example**:
- Suppose the price of a Treasury note is quoted as **$(p1)**-**$(p2)**.
- For \$100 par value, the quoted price of **$(p1)**-**$(p2)** refers to a dollar price of $p1 dollars plus $p2 ``32^{\\textrm{nd}}`` of a dollar.
- In short, the price is calculated as 
	
\$$p1 + \\frac{$p2}{32} = $(p1+p2/32.0)\$	
 
- This means that the price per \$ 100 par value is \$$(p1+p2/32.0).
")

# ╔═╡ 46566086-d518-49d9-b173-f66f2ea0e131
md"""
The 32nd are themselves often split by the addition of a **plus** sign or a **third** digit. 
- ``+`` sign means 1/64$^{\textrm{th}}$
- A _third_ digit means that this third digit is multiplied by 1/256.
"""

# ╔═╡ 4d4f241f-83c4-4a78-87e9-6ecfde56b860
md"""
##
"""

# ╔═╡ f01f940c-233c-4b90-882b-bd9d33c6b841
md"""
- Points: $(@bind p3 Slider(90:1:120, default=98, show_value=true))
- 32$^{\textrm{nd}}$: $(@bind p4 Slider(10:1:31, default=25, show_value=true))
"""

# ╔═╡ 2d37c722-c5bb-4462-a48d-f9374bed4449
Markdown.parse("
**Example**:
- Suppose the price of a Treasury note is quoted as **$(p3)**-**$(p4)+**.
- For \$100 par value, the quoted price of **$(p3)**-**$(p4)+** refers to a dollar price of $p3 dollars plus $p4 ``32^{\\textrm{nd}}`` plus 1 ``64^{\\textrm{th}}``of a dollar.
- In short, the price is calculated as 
	
\$$p3 + \\frac{$p4}{32} + \\frac{1}{64}= $(p3+p4/32.0+1/64.0)\$	
 
- This means that the price per \$ 100 par value is \$$(p3+p4/32.0+1/64.0)\$.
")

# ╔═╡ b541d16f-59da-48dd-b7f6-a0cebd451256
md"""
##
"""

# ╔═╡ b294a20b-8710-49bb-a069-75dbc3f19ba6
md"""
- Points: $(@bind p5 Slider(90:1:120, default=98, show_value=true))
- 32$^{\textrm{nd}}$: $(@bind p6 Slider(10:1:31, default=25, show_value=true))
- 256$^{\textrm{th}}$: $(@bind p7 Slider(1:1:9, default=2, show_value=true))
"""

# ╔═╡ 64adcfde-8ade-4778-bb01-9d46ee836a55
Markdown.parse("
**Example**:
- Suppose the price of a Treasury note is quoted as **$(p5)**-**$(p6)$(p7)**.
- For \$100 par value, the quoted price of **$(p5)**-**$(p6)$(p7)** refers to a dollar price of $p5 dollars plus $p6 ``32^{\\textrm{nd}}`` plus $(p7) ``256^{\\textrm{th}}``of a dollar.
- In short, the price is calculated as 
	
\$$p5 + \\frac{$p6}{32} + \\frac{$p7}{256}= $(p5+p6/32.0+p7/256.0)\$	
 
- This means that the price per \$ 100 par value is \$$(p5+p6/32.0+p7/256.0)\$.
")

# ╔═╡ c3f25830-c6d2-4d77-bbd6-91024ee3363b
md"""
##
"""

# ╔═╡ f72ab26d-f986-4ab3-9f15-11cb33b65c69
md"""
- Points: $(@bind p11 Slider(90:1:120, default=98, show_value=true))
- 32$^{\textrm{nd}}$: $(@bind p12 Slider(10:1:31, default=25, show_value=true))
- Quarters of a 32$^{\textrm{nd}}$: $(@bind p13 Slider(1:1:3, default=1, show_value=true))
"""

# ╔═╡ e68723a6-a1d8-4a3f-8ba0-9acab5d764db
Markdown.parse("
**Example**:
- Often, trading system such as Bloomberg display _fractions_ after the ``32^{\\textrm{nd}}``.
- Suppose the price of a Treasury note is quoted as ``\\mathbf{$p11 - $p12 \\frac{$p13}{4}}``.
- For \$100 par value, the quoted price of ``\\mathbf{$p11 - $p12 \\frac{$p13}{4}}`` refers to a dollar price of $p11 dollars plus ``($p12 + \\frac{$p13}{4})`` ``32^{\\textrm{nd}}`` of a dollar.
- In short, the price is calculated as 
	
\$$p11 + \\frac{$p12+\\frac{$p13}{4}}{32} = $(p11+(p12+0.25*p13)/32.0)\$	
 
- This means that the price per \$ 100 par value is \$$(p11+(p12+0.25*p13)/32.0)\$.
")

# ╔═╡ bbf515d0-e8a2-4391-8e86-41e814e3240a
md"""
##
"""

# ╔═╡ b5ed2793-df92-4f41-97e9-7533b35db4c0
md"""
- Points: $(@bind p14 Slider(90:1:120, default=98, show_value=true))
- 32$^{\textrm{nd}}$: $(@bind p15 Slider(10:1:31, default=25, show_value=true))
- Eights of a 32$^{\textrm{nd}}$: $(@bind p16 Slider(1:1:7, default=1, show_value=true))
"""

# ╔═╡ b65c747b-f08a-408d-8e01-e921dcbd9056
Markdown.parse("
**Example**:
- One last example. Suppose the price of a Treasury note is quoted as ``\\mathbf{$p14 - $p15 \\frac{$p16}{8}}``.
- For \$100 par value, the quoted price of ``\\mathbf{$p14 - $p15 \\frac{$p16}{8}}`` refers to a dollar price of $p14 dollars plus ``($p15 + \\frac{$p16}{8})`` ``32^{\\textrm{nd}}`` of a dollar.
- In short, the price is calculated as 
	
\$$p14 + \\frac{$p15+\\frac{$p16}{8}}{32} = $(p14+(p15+1/8*p16)/32.0)\$	
 
- This means that the price per \$ 100 par value is \$$(p14+(p15+1/8*p16)/32.0)\$.
")

# ╔═╡ 2200d50b-f23f-4764-85e1-d908b5aeeb1e
md"""
##
"""

# ╔═╡ 16a751d5-9a6b-40c4-969f-46c2d184c8c6
Markdown.parse("
!!! important
- In some trading system, hyphens in quotes such as in **$(p1)-$(p2)** are replaced with a decimal points. 
- That is the quote is displayed as **$(p1).$(p2)**
- The interpretation is the same. Thus, the price per \$100 par value is \$$(p1+p2/32.0).
\$$p1 + \\frac{$p2}{32} = $(p1+p2/32.0)\$	
")

# ╔═╡ 4576f508-91bd-4fdc-a62d-833d8428f78f
md"""
## Practice Exercise
For each quoted price shown below, enter the price per \$100 par value in decimals.
"""

# ╔═╡ 6c57bd92-7d1d-41d3-88d5-0b2c191b7693
begin
	p161=100
	p162=27
	
	p171=108
	p172=31
		
	p181=102
	p182=12
	p183=3
	
	p191=102
	p192=18
	p193=1
	display("")
end

# ╔═╡ 9a1aa162-d274-4af7-8f13-5a9d6bab98b0
Markdown.parse("""
- Quoted Price: ``$p161 - $p162`` 
""")

# ╔═╡ 4bccc40c-953a-4969-b47b-aea4b234919b
Markdown.parse("""
!!! hint
    Price in Decimals: ``$(p161+p162/32)``
""")

# ╔═╡ 176d61b1-02d9-4da6-a893-72aca3541f2c
md"""
##
"""

# ╔═╡ 729198d1-5795-4b70-85f8-f25717edc244
Markdown.parse("""
- Quoted Price: ``$p171 - $p172 +`` 
""")

# ╔═╡ 301c4a13-814e-4853-aa5b-aac611cc40f0
Markdown.parse("""
!!! hint
    Price in Decimals: ``$(p171+p172/32+1/64)``
""")

# ╔═╡ feb4fbca-0a01-445a-b4e1-d50b3f3525a3
md"""
##
"""

# ╔═╡ 9aa0dec2-c1e1-41c5-9ad5-35b51e41128a
Markdown.parse("""
- Quoted Price: ``$p181 - $p182 \\frac{$p183}{4}`` 
""")

# ╔═╡ 3a2a5dea-4a07-4368-89c9-cde995b9964b
Markdown.parse("""
!!! hint
    Price in Decimals: ``$(p181+(p182+p183/4)/32)``
""")

# ╔═╡ d79b4d61-8211-4fca-a83c-46db3959d51e
md"""
##
"""

# ╔═╡ a4670db5-20e5-41cd-a2af-8dd15ce119f6
Markdown.parse("""
- Quoted Price: ``$p191 - $p192 \\frac{$p193}{8}`` 
""")

# ╔═╡ 16d95a82-743e-478c-a50d-36e800910883
Markdown.parse("""
!!! hint
    Price in Decimals: ``$(p191+(p192+p193/8)/32)``
""")

# ╔═╡ be1e2ae2-8b05-42c7-bc54-18c9ff111854
md"""
# Accrued Interest
"""

# ╔═╡ 8464e17a-2f95-4bde-8c37-502359bb2dd8
LocalResource("./TreasuryNoteDescrExampleBloomberg_2.png",:width => 1200) 

# ╔═╡ 59023ef2-e4fb-4e41-9652-67f6a107e1b1
md"""
##
"""

# ╔═╡ a7c9120b-ee24-48c2-904a-e40ef95fcffa
LocalResource("./TreasuryNoteDescrExampleBloombergDirtyPrice_2.png",:width => 1200) 

# ╔═╡ 148712ae-b638-45de-9ab1-96492f083439
md"""
##
"""

# ╔═╡ 8f9498b5-a1cf-4be7-b0dd-41aad76c959b
md"""
- U.S. Treasury securities pay coupon interest every six months.
- At any date between two coupon payments, we must take the **accrued interest** into account.
- The convention in the Treasury market is that _in addition to_ the **quoted price**, the bond buyer must _pay_ the bond seller the **accrued interest**.
- Thus, the amount that the buyer pays the seller is the **quoted price** plus **accrued interest**.
  - This is the actual purchase price and it is called the **dirty price.**
  - The **quoted price** of a bond (_without accrued interest_) is called the **clean price.**
- The **clean price** is also called the **flat** price and the **dirty price** is also called the **full** price.
"""

# ╔═╡ 6ce18679-b433-4110-8ef4-0fd9135737f4
md"""
> - How to get there on the Bloomberg terminal?
>   - On the keyboard type `T Govt`
>   - Click on `United States Treasury Note/Bond (Multiple Matches) Govt`
>   - On the next page, click on one of the Treasury notes/bonds.
>   - Next, type `DES` on the keyboard and press enter.
>   - The page you now see is the `Description` page for the Treasury you selected.
>   - Next, type `HP` and press enter.
>   - This will display a page with past prices for the Treasury note/bond you selected.
>   - Next, at the top, in the row labeled `Market` type in __Mid Line__ in the first field and __Dirty Mid Price__ in the second field. Press enter.
>   - The price table will now show the *clean* mid price and the *dirty* mid price.
>     - Recall that the *mid* price is the midpoint between the bid and the ask price.  
"""

# ╔═╡ 1c3d5c02-4be2-4aff-bac8-bfde4aca679a
md"""
## Full Prices of Treasury Notes/Bonds over Time
"""

# ╔═╡ c90f441d-09ca-4562-8f3f-d766e166d2a4
md"""
On the coupon payment data, the Treasury trades `ex-coupon` and its *full price* (also referred to as the *dirty price*) drops by the amount of the coupon interest cash flow.
"""

# ╔═╡ ee211d3e-08c0-4a4c-8c79-8d5e709981ef
LocalResource("./BloombergTreasuryDirtyPricePath.png", :width=>1200)

# ╔═╡ 90501d6d-5c09-4bae-9415-dedd93dca242
LocalResource("./BloombergTreasuryDirtyPricePath_02.png", :width=>1200)

# ╔═╡ d440a3c8-6c8b-4eb9-ab4d-266917d50ee0
md"""
- Let' check this.
- The screenshot shows that the price change on the ex-coupon date is `0-28`.
- This is a dollar price (per \$100 notional) of $\frac{28}{32}=$ \$0.875.
- The Treasury note has a coupon rate of `1-3/4` percent (see the top left).
- In decimals, this is a couponr ate of 1.75%.
- Thus, the semi-annual coupon cash flow per \$100 face value is $\frac{1.75}{2}\ \times 100$ = \$0.875.
- Thus, the price decline matches the dollar coupon interest paid on this data.
"""

# ╔═╡ 18026407-34e8-4a96-aaaf-410d495f9568
md"""
## Example
"""

# ╔═╡ 6acadc8a-dbb7-4193-9df7-09504755476b
md"""
- Days between coupon payments: 180
- Coupon rate [% p.a.]: $(@bind cpnAI_1 Slider(0:1:10, default=2, show_value=true))

- Days after previous coupon: $(@bind daysAI_1 Slider(1:1:180, default=60, show_value=true))
- Days to next coupon: $(180-daysAI_1)
"""

# ╔═╡ 362273d3-e019-4953-a1dd-21699f7a7def
Markdown.parse("""
- To illustrate, suppose a Treasury note has a coupon rate of $(cpnAI_1) % (paid semi-annually) and that there are 180 days between coupon payments.
- Suppose you own \$ 100 par value of this Treasury note and that $(daysAI_1) days have passed since the previous coupon cash flow.
- The next coupon cash flow in $(180-daysAI_1) days is 
\$\\frac{$cpnAI_1\\%}{2} \\times 100 = $((cpnAI_1/100)/2*100)\$	

""")

# ╔═╡ 64f2d537-0735-440a-a040-008bc75d4e46
md"""
##
"""

# ╔═╡ 20fc5dfa-55a2-4b90-b57d-9e57e2430ae1
Markdown.parse("""
- Now, suppose you decide to sell the Treasury note.
- When you sell the Treasury note, you no longer receive the coupon cash flow in $(180-daysAI_1) days. 
- The buyer receives the full coupon interest of \$ $((cpnAI_1/100)/2*100).
- However, you owned the bond for $(daysAI_1) out of the 180 days between coupon interest cash flows.
- Thus, you should be entitled to receive a fraction equal to \$\\frac{$daysAI_1}{180} = $(roundmult(daysAI_1/180,1e-2))\$ of the total  $((cpnAI_1/100)/2*100) coupon interest.
- This amount of \$ $(roundmult(daysAI_1/180 * (cpnAI_1/100)/2*100,1e-2)) is referred to as **accrued interest** and it is added to the *quoted* price.
- The total price paid by the buyer is called the **full price** or the **dirty price**.
- The quoted price (without accrued interest) is called the **flat price** or the **clean price**.
- Thus,
\$\\textrm{Full Price}=\\textrm{Flat Price} + \\textrm{Accrued Interest}\$
\$\\textrm{or}\$
\$\\textrm{Dirty Price}=\\textrm{Clean Price} + \\textrm{Accrued Interest}\$
""")

# ╔═╡ 2cf47487-36c3-4a28-976e-06a58675b306
md"""
##
"""

# ╔═╡ 577c5da8-de61-4f41-96f3-957c4fa93cd2
begin
	
	daysAI_2 = repeat(collect(0:179),3)
	cpnAI_2 = ((cpnAI_1/100)/2*100).*daysAI_2/180
	plot(cpnAI_2,xticks = ( [0:30:length(daysAI_2);], string.(daysAI_2[1:30:end])),
		ylabel="Accrued Interest",xlabel="Days since last coupon", label=""
	)
	
	 
end

# ╔═╡ cedc6044-5eb2-4e95-98c7-e5831597a258
md"""
## Calculating Accrued Interest for Treasury notes and bonds
"""

# ╔═╡ d43ce5da-dee3-4d44-a202-4f5f4770772b
md"""
- To calculate accrued interest, the following are needed: 
  - the number of days in the accrued interest period (represents the number of days over which the investor has earned interest)
  - the number of days in the coupon period (representes the number of days between the last and the next coupon payment)
  - the dollar amount of the coupon payment
"""

# ╔═╡ a4a0a069-80d6-4a13-a19d-56b200ca8545
md"""
- Accrued Interest is the calculated as
$$\textrm{Accrued Interest} = \textrm{Coupon Interest Cash Flow} \times \left( \frac{ \textrm{Days in Accrued Interest Period}}{\textrm{Days in Coupon Period}} \right)$$
"""

# ╔═╡ b71c4b72-7004-4600-82d4-651179178a03
md"""
## 1. Calculate the **Days in Accrued Interest Period**

- We need three key dates: 
- **Trade date**
  - The trade date (also referred to as the transaction date) is the date on which the transaction is executed (referred to as “T”).
- **Settlement date** 
  - The settlement date is the date a transaction is deemed to be completed and the seller must transfer the ownership of the bond to the buyer in exchange for the payment.
  - Treasury securities settle on the next business day after the trade date. This is referred to as *T+1 Settlement*.
- **Date of previous coupon cash flow**
- Days in Accrued Interest Period are then calculated as

$$\textrm{Days in Accrued Interest Period=}$$ 
$$\textrm{Days from and \textbf{including} the previous coupon date up to \textbf{excluding} the settlement date}$$
"""

# ╔═╡ fd4aead4-bf25-4125-b094-6edce0e77b1e
md"""
## 2. Calculate the **Days in Coupon Period**
- Simply the number of days between the previous coupon date and the next coupon date.
"""

# ╔═╡ fcaff09a-c014-4fe9-81f8-f0fb72d99829
md"""
## Example
"""

# ╔═╡ 8323c2cc-cc29-416b-aca4-798f7cc844ed
md"""
- Consider a Treasury note whose previous coupon payment was May 15. Assume that the coupon rate is 8% p.a. (paid semi-annually) and par value of \$100.
  - Thus, the coupon interest cash flows are $\frac{8\%}{2}\times 100 =$ \$4
- Suppose you buy Treasury security with a settlement date of September 10.
- Since Treasury notes pay semi-annual coupon interest, the next coupon payment is on November 15. 
"""

# ╔═╡ 9119860b-2ada-411a-95e7-e1e56ae573c0
md"""
##
- **Step 1**: *Days in Accrued Interest Period*
  - We count the actual number of days between May 15 (the previous coupon date) and September 10 (the settlement date). 
    - May: **17** days (we count the day of the previous coupon cash flow)
    - June: 30 days
    - July: 31 days
    - August: 31 days
    - September: **9** days (we do not count the settlement date)
   - Thus, *Days in Accrued Interest Period* = 118
"""

# ╔═╡ 8dc2cccb-a682-4c42-99fe-ccc91d3823d1
md"""
##
- **Step 2**: *Days in Coupon Period*
  - We count the actual number of days between May 15 (the previous coupon date) and Nov 15 (the next coupon date)
    - May: **16 days**
    - June: 30 days
    - July: 31 days
    - September: 30 days
    - October: 31 days
    - November: **15 days**
  - Thus, *Days in Coupon Period*=184
"""

# ╔═╡ c6df152f-9f62-4eb4-997e-afd9a0868c9e
md"""
##
- **Step 3**: *Accrued Interest*
$$\textrm{Accrued Interest} = \textrm{Coupon Interest Cash Flow} \times \left( \frac{ \textrm{Days in Accrued Interest Period}}{\textrm{Days in Coupon Period}} \right)$$
$$\textrm{Accrued Interest} = \textrm{\$4} \times \left( \frac{ \textrm{118}}{\textrm{184}} \right) = \textrm{\$4} \times 0.641304 = \textrm{\$2.565217}$$
"""

# ╔═╡ 41b91a85-ac56-4b36-87e1-b121c756417e
md"""
## Accrued Interest Example 2
"""

# ╔═╡ 4d039efd-c682-4abe-a2a4-8536ed97a3c7
md"""
- Coupon rate [% p.a.]: $(@bind cpnAI_3 Slider(0:0.25:10, default=2.5, show_value=true))
- Par value [\$]: $(@bind par_3 Slider(100:100000, default=100, show_value=true))
- Previous coupon cash flow date: $(@bind prev_3 DateField(default=Date(2015,7,15)))
- Next coupon cash flow date: $(@bind next_3 DateField(default=Date(2016,01,15)))
- Settlement date: $(@bind settle_3 DateField(default=Date(2015,10,10)))
"""

# ╔═╡ 5752193f-de1f-4832-ab93-a0fc8c4d9c4d
begin 
	daysAIPeriod = Date(settle_3) - Date(prev_3)
	daysCpnPeriod = Date(next_3) - Date(prev_3)
	accrInt_3 = Dates.value(daysAIPeriod)/Dates.value(daysCpnPeriod)*cpnAI_3/(200)*
par_3
	md"""
	- Coupon interest cash flow:  $(roundmult(par_3 * (cpnAI_3/200),1e-6))
	- Number of Days in Accrued Interest Period: $(daysAIPeriod)
	- Number of Days in Coupon Period: $(daysCpnPeriod)
	"""
end

# ╔═╡ 7b376a7e-215e-40af-82af-6be2762aa7eb
Markdown.parse("""
``\\begin{align}
\\textrm{Accrued Interest} &= \\textrm{Coupon Interest Cash Flow} \\times \\left( \\frac{ \\textrm{Days in Accrued Interest Period}}{\\textrm{Days in Coupon Period}} \\right)\\\\ 
&= \\\$ $(roundmult(cpnAI_3/(200)*par_3,1e-6)) \\times \\frac{$(Dates.value(daysAIPeriod)) \\textrm{ days}}{$(Dates.value(daysCpnPeriod)) \\textrm{ days}} =\\\$ $(roundmult(accrInt_3,1e-6))
\\end{align}``
""")

# ╔═╡ 70661dd7-0acf-4b6c-b7dd-f4ad71c1cee9
md"""
# Daycount Conventions
- In calculating the number of days between two dates, the actual number of days is **not** always the same as the number of days that should be used in the accrued interest formula.
- The number of days used depends on the **day count convention** for the particular security.
- For Treasury notes/bonds, the day count convention is to use the **actual** number of days between two dates.
  - This is referred to as the **actual/actual** day count convention.
"""

# ╔═╡ 6e1be79b-bfc7-444e-b660-e0d24a2cf5dd
md"""
##
- For coupon-bearing agency, municipal, and corporate bonds, a different day count convention is used.
- It is assumed that every month has **30 days**, that any 6-month period has **180 days**, and that there are **360 days** in a year.
- This day count convention is referred to as **30/360.**
- The calculations are analogous to the examples we covered, except that 30 days are used for each month.
"""

# ╔═╡ e4c4606f-bb51-43c6-98b7-73e1b133b251
md"""
##
- To illustrate the “30/360” convention, suppose the **settlement date** is *July 17* and the *previous coupon cash flow* was on *May 15*.
- The number of days between May 15 and July 17 is 62 days, 
  - May is assumed to have 30 days. Thus we count 16 days in May (remember to include the date of the previous coupon cash flow).
  - The month of June is assumed to have 30 days, so we add 30 days.
  - In July, we count 16 days (remember to exclude the settlement date)
  - So the total number of days is 16 days + 30 days + 16 day = 62 days.
"""

# ╔═╡ a81f9bd5-374d-4238-af83-e39ab1f5982e
md"""
# Price Quotes of Treasury Bills
"""

# ╔═╡ bb8b0b23-4313-4764-96bd-c1e34aa09795
md"""
## Example: 52-week Treasury Bill in Bloomberg
- On the Bloomberg Terminal type `912796M89` and click on the security in the search result. 
- Next, type `DES` and `Enter`.
"""

# ╔═╡ a93b91d5-7239-4260-b57f-7afb02ee31c5
LocalResource("./TreasuryBillDescrExampleBloomberg.png",:width => 1200) 

# ╔═╡ dcb12edc-553b-4fe7-9525-a86d9fd5a78a
md"""
## Price Quotes for 52-week Treasury Bill
- On the Bloomberg Terminal click on `ALLQ` under _Quick Links_
"""

# ╔═╡ 25500a55-9c69-42d8-87bf-fb897b6de939
LocalResource("./TreasuryBillPriceQuoteBloomberg.png",:width => 1200) 

# ╔═╡ 71684c1d-0204-477b-a838-175f38e8c367
md"""
>- How to get there on the Bloomberg terminal?
>  - On the keyboard type `B Govt`
>  - Click on `United States Treasury Bill (Multiple Matches)`
>  - On the next page, click on one of the Treasury bills.
>  - Next, type `DES` on the keyboard and press enter.
>  - The page you now see is the `Description` page for the Treasury bill you selected.
>  - Next, type `ALLQ` and press enter.
>  - This will display a page with quoted prices for the Treasury bill you selected.
"""

# ╔═╡ 9d874ab6-e3ec-4a87-8842-a8a8074b745c
md"""
## Treasury Bill Price Quoting Convention
"""

# ╔═╡ a92a604a-429b-4508-9820-c99839f3b431
md"""
- The convention for quoting prices for Treasury bills is **not** the same as for Treasury bonds.
- Treasury bill prices are quoted as yields on **bank discount basis**.
- The yield on a bank discount basis $y_d$ for $100 par value is computed as follows: 
$$y_d = \frac{100-\textrm{Price}}{100} \times \left( \frac{360}{\textrm{Days to Maturity}} \right)$$
- where $\textrm{Price}$ is the purchase price of the Treasury bill and $\textrm{Days to Maturity}$ is the number of days until the maturity date of the Treasury bill.
- In calculating the $\textrm{Days to Maturity}$ Treasury bills use the **actual/360** convention.
  - Thus, the number of days between two dates is the **actual** number of days.
  - Each year is assumed to have **360** days.
- Note that the term in the numerator is essentially the dollar **discount** (the difference between par value and the purchase price).
"""

# ╔═╡ 4f6af650-763a-4c56-a564-d3c1447be1fd
Markdown.parse("
## Example Calculating the Discount Yield given the Price
- Consider a Treasury bill with 85 days to maturity, a face value of 100, and a purchase price of 99.10.
- This Treasury bill would be quoted with a discount yield \$y_d\$ of
\$y_d = \\frac{100-99.10}{100} \\times \\frac{360}{85}= $(roundmult((100-99.10)/100*360/85,1e-6))=$(roundmult((100-99.10)*(360/85),1e-6))\\%\$ 
")

# ╔═╡ 28112b4a-fbeb-4409-b3f7-88578191a704
md"""
## Example Calculating Price given the Discount Yield
"""

# ╔═╡ 443d90d3-a408-4f0a-b1c0-8e2cdfc1970a
md"""
- Let us now consider the possibly more typical case where we want to know the dollar price given a discount yield quote from the Bloomberg system.
"""

# ╔═╡ e2e15eb3-c339-49ea-85b6-5436835cddea
md"""
Example from Bloomberg of the Treasury Bill with maturity on 4/30/2020
- Quote (as discount yield) on 2/07/2020.
- Settlement date is 2/10/2020.
- There are 80 days from settlement date to maturity.
  - Note that there are 29 days in February of 2020.
  - Thus, 19 days in February + 31 days in March + 30 days in April = 80 days.
"""

# ╔═╡ 448e7b7e-b4b7-4eec-a331-f72f6aac7ff2
LocalResource("./TbillExampleBloomberg_1.svg",:width => 1200) 

# ╔═╡ 4044d433-857f-47f6-8947-597935a981a1
md"""
##
"""

# ╔═╡ 61228793-317c-40a2-b9f8-cb661704f799
md"""
Quoted discount yield on 02/07/2020.
"""

# ╔═╡ e88cafc2-ad9a-4c46-bbc6-2f442ce0615a
LocalResource("./TreasuryBillPriceQuoteBloomberg_3.svg",:width => 300) 

# ╔═╡ 2ecb026c-c7ea-41a4-ac2b-b518b7fd5f05
md"""
##
"""

# ╔═╡ 7b091f73-2454-4690-b1f9-3f0008561da9
md"""
What is the purchase price?
- Simply solve the equation for the discount yield $y_d$ for the price.

$$P = 100 \times \left( 1- y_d \times \frac{\textrm{Days to Maturity}}{360}\right)$$
"""

# ╔═╡ d5c4c319-a544-4546-847f-f5f384ee4494
md"""
##
"""

# ╔═╡ 574ee503-37f4-4d27-8bc2-7688b60fe839
md"""
- Using the quoted discount yield

$$P=100 \times \left( 1- y_d \times \frac{\textrm{Days to Maturity}}{360}\right)= 
\$100 \times \left( 1- 1.5225\% \times \frac{80}{360}\right)=\$99.6617$$
"""

# ╔═╡ 2e81e8dc-cdef-4965-84a4-bdd1513d09f9
md"""
##
"""

# ╔═╡ 80e6068f-5876-47c0-a5e8-17125b54de63
md"""
- Let's verify
"""

# ╔═╡ d11d60be-9909-47c6-8ce9-438e2cf28d6f
LocalResource("./TreasuryBillPriceQuoteBloomberg_2.svg",:width => 300) 

# ╔═╡ 5a00909a-8279-46ef-8570-bbbb7adffcf4
md"""
## Example
- Quoted discount yield [% p.a.]: $(@bind yd_4 Slider(0:0.01:3, default=1.85, show_value=true))
- Par value [\$]: $(@bind par_4 Slider(100:1000, default=100, show_value=true))
- Settlement date: $(@bind settle_4 DateField(default=Date(2022,03,1)))
- Maturity date: $(@bind mat_4 DateField(default=Date(2022,3,31)))
"""

# ╔═╡ 2e4b644c-9b50-42fe-9775-2619baff2518
begin 
	daysMat = Date(mat_4) - Date(settle_4)
	px_4 = (1-yd_4/100*Dates.value(daysMat)/360)*par_4
	md"""
	- Number of days to maturity: $(daysMat)
	- Dollar Price: \$ $(roundmult(px_4,1e-6)) per \$$(par_4) notional amount.
	"""
end

# ╔═╡ 628ba57e-39ee-4072-8935-c44fae56b0bd
Markdown.parse("
- This Treasury bill has a dollar purchase price of 
``P=\\\$100\\times\\left(1 - y_d \\times \\frac{\\textrm{Days to Maturity}}{360}\\right)=\\\$100\\times \\left(1 - $yd_4\\% \\times \\frac{$(Dates.value(daysMat))}{360} \\right) = \\\$ $(roundmult(px_4,1e-6))`` per \$ $(par_4) notional.
")

# ╔═╡ 371a326e-f13b-44ce-91e8-50d43b7ae59a
md"""
# Treasury STRIPS
"""

# ╔═╡ b7bdc144-7648-403f-bce7-2b6df6a8dd2f
md"""
- The Treasury does not issue **zero**-coupon notes or bonds. 
- However, by “stripping” coupon payments from Treasury bonds, zero coupon bonds are created synthetically. 
- The process of separating the interest on a bond from the underlying principal is called coupon stripping.

"""

# ╔═╡ 31c17b01-eb86-4fd4-82cc-3c31cf3020d8
md"""
##
"""

# ╔═╡ fe72e3e8-a2b4-43b2-811d-5f4fe2c8dd7a
LocalResource("./TreasurySTRIPS_1.png",:width => 1200) 

# ╔═╡ 3222f82c-b513-403b-b4c5-22d89144f894
md"""
##
"""

# ╔═╡ 02748d79-5707-4130-9aae-0c6141e4f760
LocalResource("./TreasurySTRIPS_2.png",:width => 600) 

# ╔═╡ d01a85dd-1fd5-4b4e-9ff6-6de1f94d1752
md"""
##
"""

# ╔═╡ 1217e6ec-8479-4a85-b0e7-088eee30bc63
md"""
- Zero-coupon Treasury securities were first created in August 1982 by large dealer firms on Wall Street. 
- Today, all Treasury notes and bonds (fixed-principal and inflation-indexed) are eligible for stripping. 
- The zero-coupon Treasury securities created under the STRIPS program are direct obligations of the U.S. government.
- Strips created from the Treasury coupons are called **coupon STRIPS** and those from the principal are called **principal STRIPS**. 
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
        <input type="checkbox" value="" checked>Understand how prices for Treasury securities are quoted in secondary markets.<br><br>
	    <input type="checkbox" value="" checked>Know how to calculate accrued interest.<br><br>
	</fieldset>      
	"""
end

# ╔═╡ 2ee2c328-5ebe-488e-94a9-2fce2200484c
md"""
## Reading
Fabozzi, Fabozzi, 2021, Bond Markets, Analysis, and Strategies, 10th Edition\
Chapter 7 and Chapter 2
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
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.2.2"
HTTP = "~0.9.17"
HypertextLiteral = "~0.9.1"
LaTeXStrings = "~1.2.1"
Plots = "~1.22.6"
PlutoUI = "~0.7.16"
XLSX = "~0.7.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

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
git-tree-sha1 = "8d954297bc51cc64f15937c2093799c3617b73e4"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.10.0"

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
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

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
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

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
git-tree-sha1 = "d189c6d2004f63fd3c91748c458b09f26de0efaa"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.61.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

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
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

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
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

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
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

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
git-tree-sha1 = "98f59ff3639b3d9485a03a72f3ab35bab9465720"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.6"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "ba43b248a1f04a9667ca4a9f782321d9211aa68e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.6"

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

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "69fd065725ee69950f3f58eceb6d144ce32d627d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.2"

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
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

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
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

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

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

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
# ╟─c3e429e4-e7e9-4db6-852c-906630f909a4
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3e995602-7a5e-45ce-a31d-449951af1aea
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─93db6880-429c-4b9c-a807-eba600e03df1
# ╟─1fa89db5-8185-4c32-81ad-4cc7e4ec44c4
# ╟─aac27a3c-e90a-437f-a563-f81d41c8d3f7
# ╟─39af52c6-ddb1-41ec-be5c-c0e31a2693bb
# ╟─6561b7a0-368c-43c6-ada9-36b83dc4a749
# ╟─15cb9e60-6e54-4f0e-abb2-9249bdc49677
# ╟─30ce6f74-1d7e-465d-abf1-245881fec53b
# ╟─5bfbddd7-c014-45c1-871d-ae41d5c02c82
# ╟─395335f3-3f6c-4fbc-bf0b-9a238c8b6864
# ╟─4ad79093-2e8b-4fd7-bc1d-87388947ffde
# ╟─46566086-d518-49d9-b173-f66f2ea0e131
# ╟─4d4f241f-83c4-4a78-87e9-6ecfde56b860
# ╟─2d37c722-c5bb-4462-a48d-f9374bed4449
# ╟─f01f940c-233c-4b90-882b-bd9d33c6b841
# ╟─b541d16f-59da-48dd-b7f6-a0cebd451256
# ╟─64adcfde-8ade-4778-bb01-9d46ee836a55
# ╟─b294a20b-8710-49bb-a069-75dbc3f19ba6
# ╟─c3f25830-c6d2-4d77-bbd6-91024ee3363b
# ╟─e68723a6-a1d8-4a3f-8ba0-9acab5d764db
# ╟─f72ab26d-f986-4ab3-9f15-11cb33b65c69
# ╟─bbf515d0-e8a2-4391-8e86-41e814e3240a
# ╟─b65c747b-f08a-408d-8e01-e921dcbd9056
# ╟─b5ed2793-df92-4f41-97e9-7533b35db4c0
# ╟─2200d50b-f23f-4764-85e1-d908b5aeeb1e
# ╟─16a751d5-9a6b-40c4-969f-46c2d184c8c6
# ╟─4576f508-91bd-4fdc-a62d-833d8428f78f
# ╟─6c57bd92-7d1d-41d3-88d5-0b2c191b7693
# ╟─9a1aa162-d274-4af7-8f13-5a9d6bab98b0
# ╟─4bccc40c-953a-4969-b47b-aea4b234919b
# ╟─176d61b1-02d9-4da6-a893-72aca3541f2c
# ╟─729198d1-5795-4b70-85f8-f25717edc244
# ╟─301c4a13-814e-4853-aa5b-aac611cc40f0
# ╟─feb4fbca-0a01-445a-b4e1-d50b3f3525a3
# ╟─9aa0dec2-c1e1-41c5-9ad5-35b51e41128a
# ╟─3a2a5dea-4a07-4368-89c9-cde995b9964b
# ╟─d79b4d61-8211-4fca-a83c-46db3959d51e
# ╟─a4670db5-20e5-41cd-a2af-8dd15ce119f6
# ╟─16d95a82-743e-478c-a50d-36e800910883
# ╟─be1e2ae2-8b05-42c7-bc54-18c9ff111854
# ╟─8464e17a-2f95-4bde-8c37-502359bb2dd8
# ╟─59023ef2-e4fb-4e41-9652-67f6a107e1b1
# ╟─a7c9120b-ee24-48c2-904a-e40ef95fcffa
# ╟─148712ae-b638-45de-9ab1-96492f083439
# ╟─8f9498b5-a1cf-4be7-b0dd-41aad76c959b
# ╟─6ce18679-b433-4110-8ef4-0fd9135737f4
# ╟─1c3d5c02-4be2-4aff-bac8-bfde4aca679a
# ╟─c90f441d-09ca-4562-8f3f-d766e166d2a4
# ╟─ee211d3e-08c0-4a4c-8c79-8d5e709981ef
# ╟─90501d6d-5c09-4bae-9415-dedd93dca242
# ╟─d440a3c8-6c8b-4eb9-ab4d-266917d50ee0
# ╟─18026407-34e8-4a96-aaaf-410d495f9568
# ╟─6acadc8a-dbb7-4193-9df7-09504755476b
# ╟─362273d3-e019-4953-a1dd-21699f7a7def
# ╟─64f2d537-0735-440a-a040-008bc75d4e46
# ╟─20fc5dfa-55a2-4b90-b57d-9e57e2430ae1
# ╟─2cf47487-36c3-4a28-976e-06a58675b306
# ╟─577c5da8-de61-4f41-96f3-957c4fa93cd2
# ╟─cedc6044-5eb2-4e95-98c7-e5831597a258
# ╟─d43ce5da-dee3-4d44-a202-4f5f4770772b
# ╟─a4a0a069-80d6-4a13-a19d-56b200ca8545
# ╟─b71c4b72-7004-4600-82d4-651179178a03
# ╟─fd4aead4-bf25-4125-b094-6edce0e77b1e
# ╟─fcaff09a-c014-4fe9-81f8-f0fb72d99829
# ╟─8323c2cc-cc29-416b-aca4-798f7cc844ed
# ╟─9119860b-2ada-411a-95e7-e1e56ae573c0
# ╟─8dc2cccb-a682-4c42-99fe-ccc91d3823d1
# ╟─c6df152f-9f62-4eb4-997e-afd9a0868c9e
# ╟─41b91a85-ac56-4b36-87e1-b121c756417e
# ╟─4d039efd-c682-4abe-a2a4-8536ed97a3c7
# ╟─5752193f-de1f-4832-ab93-a0fc8c4d9c4d
# ╟─7b376a7e-215e-40af-82af-6be2762aa7eb
# ╟─70661dd7-0acf-4b6c-b7dd-f4ad71c1cee9
# ╟─6e1be79b-bfc7-444e-b660-e0d24a2cf5dd
# ╟─e4c4606f-bb51-43c6-98b7-73e1b133b251
# ╟─a81f9bd5-374d-4238-af83-e39ab1f5982e
# ╟─bb8b0b23-4313-4764-96bd-c1e34aa09795
# ╟─a93b91d5-7239-4260-b57f-7afb02ee31c5
# ╟─dcb12edc-553b-4fe7-9525-a86d9fd5a78a
# ╟─25500a55-9c69-42d8-87bf-fb897b6de939
# ╟─71684c1d-0204-477b-a838-175f38e8c367
# ╟─9d874ab6-e3ec-4a87-8842-a8a8074b745c
# ╟─a92a604a-429b-4508-9820-c99839f3b431
# ╟─4f6af650-763a-4c56-a564-d3c1447be1fd
# ╟─28112b4a-fbeb-4409-b3f7-88578191a704
# ╟─443d90d3-a408-4f0a-b1c0-8e2cdfc1970a
# ╟─e2e15eb3-c339-49ea-85b6-5436835cddea
# ╟─448e7b7e-b4b7-4eec-a331-f72f6aac7ff2
# ╟─4044d433-857f-47f6-8947-597935a981a1
# ╟─61228793-317c-40a2-b9f8-cb661704f799
# ╟─e88cafc2-ad9a-4c46-bbc6-2f442ce0615a
# ╟─2ecb026c-c7ea-41a4-ac2b-b518b7fd5f05
# ╟─7b091f73-2454-4690-b1f9-3f0008561da9
# ╟─d5c4c319-a544-4546-847f-f5f384ee4494
# ╟─574ee503-37f4-4d27-8bc2-7688b60fe839
# ╟─2e81e8dc-cdef-4965-84a4-bdd1513d09f9
# ╟─80e6068f-5876-47c0-a5e8-17125b54de63
# ╟─d11d60be-9909-47c6-8ce9-438e2cf28d6f
# ╟─5a00909a-8279-46ef-8570-bbbb7adffcf4
# ╟─2e4b644c-9b50-42fe-9775-2619baff2518
# ╟─628ba57e-39ee-4072-8935-c44fae56b0bd
# ╟─371a326e-f13b-44ce-91e8-50d43b7ae59a
# ╟─b7bdc144-7648-403f-bce7-2b6df6a8dd2f
# ╟─31c17b01-eb86-4fd4-82cc-3c31cf3020d8
# ╟─fe72e3e8-a2b4-43b2-811d-5f4fe2c8dd7a
# ╟─3222f82c-b513-403b-b4c5-22d89144f894
# ╟─02748d79-5707-4130-9aae-0c6141e4f760
# ╟─d01a85dd-1fd5-4b4e-9ff6-6de1f94d1752
# ╟─1217e6ec-8479-4a85-b0e7-088eee30bc63
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
