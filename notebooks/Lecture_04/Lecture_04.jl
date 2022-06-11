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

# ╔═╡ 9dba51e3-0738-40a1-96d8-f5583cdc5729
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
	
	
	using Logging
	global_logger(NullLogger())
	display("")

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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Bond Pricing Fundamentals</b> <p>
	<p style="padding-bottom:1cm"> </p>
	<p align=center style="font-size:25px; font-family:family:Georgia"> Spring 2022 <p>
	<p style="padding-bottom:0.5cm"> </p>
	<div align=center style="font-size:20px; font-family:family:Georgia"> Prof. Matt Fleckenstein </div>
	<p style="padding-bottom:0.25cm"> </p>
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
        <input type="checkbox" value="">Calculate the present values of future cash flows, including bonds, annuities, perpetuities, and other arbitrary cash flows..<br><br>
	    <input type="checkbox" value="">Understand different compounding frequencies and be able to convert between different compounding frequencies.<br><br>
	</fieldset>      
	"""
end

# ╔═╡ f78c6a17-bee4-4fc1-bfee-a4788ebd6924
TableOfContents(aside=true, depth=1)

# ╔═╡ c4832c71-4ce1-45d8-8bfe-c145efe5928d
md"""
# Coupon Bond Cash Flows
"""

# ╔═╡ aac27a3c-e90a-437f-a563-f81d41c8d3f7
LocalResource("TreasuryNoteDescrExampleBloomberg.png",:width => 1200) 

# ╔═╡ 13102a49-65b2-4b14-824c-412894cf2a95
LocalResource("TreasuryNoteCashflowExampleBloomberg.png",:width => 1200) 

# ╔═╡ c7ffa30e-a4d9-4c3c-8495-f770dd70016d
md"""
>- How to get there on the Bloomberg terminal?
>  - Open a terminal and on the keyboard type `91282CCZ2`.
>  - In the popup window,  select the Treasury note.
>  - Next, type `DES` to get to the bond description page.
>  - Then, type `CSHF` and press enter.
"""

# ╔═╡ 65c5b8fb-cb87-4404-9a28-df32c85966c6
md"""
##
"""

# ╔═╡ f3b7e23d-00dc-441c-97a2-575737b316df
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

# ╔═╡ 0924235f-1e63-40ea-9b8f-b0625f68f8cf
begin
	CF = 0.5*C.*ones(convert(Int64,T*2))
	CF[end] += 100
	dt = collect(0.5:0.5:T)
	bar(dt,CF,label="", ylim=(0,120), xlim=(0,T+1), xticks=collect(0.0:0.5:T), xlabel="Years", ylabel="Coupon Cash Flow")
end

# ╔═╡ 7e5f2316-212e-454a-a01f-d71197ce1993
md"""
# Bond Pricing Building Blocks
"""

# ╔═╡ 93319502-aafb-4b53-a887-e1dee962464d
md"""
- Time Value of Money
- Present Value
- Future Value
- Perpetuity
- Annuity
- Law of One Price
- Short-Selling
- Pricing Treasury Bonds
- Continuous Compounding
"""

# ╔═╡ ac2c6913-cb1f-48cc-9fbe-c4bfa30f2153
md"""
# Time Value of Money and Interest Rates
- Suppose you won the lottery and you can choose to receive your prize of \$1000 today or one year from today.
- Clearly, you prefer to get the \$1,000 today instead (because you need to wait another year).
- However, suppose you were offered \$1,100 one year from today for waiting another year.
- Let's say this sounds like a fair deal to you, i.e. you are indifferent between having \$1,000 today or \$1,100 one year from today.
- How is your choice related to interest rates?
- Your choice reveals that each dollar today is worth 10% more one year from today.
$$\$1,000\times(1+10\%) \mathop  = \limits^! $1,100$$
$$\$1\times(1+10\%) \mathop  = \limits^! $1.10$$
- In other words, you require to earn interest at an annual rate of r=10%

$$\$1\times(1+r) \mathop  = \limits^! $1.10$$
$$r=\frac{\$1.10}{\$1.00}-1=0.010=10\%$$
"""

# ╔═╡ 9a6ebe29-148a-481c-bda2-1b359bfc53f0
md"""
##
"""

# ╔═╡ 78aa5d8d-c960-4898-b47c-caf5abf84ecd
md"""
- The interest rate `r` in the example reflects your individual choice.
- When we observe an interest rate `r` in financial markets, we can think of this interest rate as an aggregate of all the individual choices investors make.
- How can we use the interest rate `r` that we observe in financial markets to tell us how "the market" decides in the lottery example.
- Suppose, we observe r=5%.
- This tells us that a value today of $1,000 is worth tomorrow an amount of
$$\$1,000\times(1+r)=\$1,000\times(1+5\%)=\$1,000\times(1+0.05)=\$1,050$$
"""

# ╔═╡ 2ea69463-67cf-4205-8722-e3b81bf16c9e
md"""
##
"""

# ╔═╡ b32a9d56-3a51-42aa-b2cc-875111c9b81b
md"""
- Let's call the \$1,000 today **Present Value (PV)** and the \$1,050 to be received in one year the **Future Value (FV)**.
- Thus, in the example
$$\textrm{PV} \times (1+r) = \textrm{FV}$$
- Putting the $$\textrm{PV}$$ on the left-hand side, we have the fundamental present-value relationship.
$$\textrm{PV}=\frac{\textrm{FV}}{(1+r)}$$
"""

# ╔═╡ 5357fdfd-7691-485d-9672-867b77a01b36
md"""
##
"""

# ╔═╡ 4f253073-5860-466d-8160-db83a0568cfe
md"""
- We just looked at a one year period.
- However, it is simple to to write down the same relation when the future cash flow occurs two years from today. Then,
$$\textrm{PV}=\frac{\textrm{FV}_2}{(1+r)^2}$$
- In general, for $t$ years
$$\textrm{PV}=\frac{\textrm{FV}_t}{(1+r)^t}$$ 
- where $\textrm{FV}_t$ means the future value (FV) in $t$ years.
"""

# ╔═╡ 6325fbe2-53dd-43d4-8c88-c509ce018809
md"""
# Present Value 
"""

# ╔═╡ ba1728fd-6fc9-4194-a85c-fcee35c32d1b
md""" 
!!! important
**Annual Compounding**

The present value of a cash flow $\textrm{FV}_t$ to be received in $t$ years given the interest rate $r$ (also called discount rate) is 

$$\textrm{PV}=\frac{\textrm{FV}_t}{(1+r)^t}$$ 
"""

# ╔═╡ a1ed3653-4a46-485e-bfc3-a78797d657f9
md"""
# Future Value 
"""

# ╔═╡ d5ad6113-e839-40e0-a7d9-620167bdcd2f
md""" 
!!! important
**Annual Compounding**

The future value $\textrm{FV}_t$ in $t$ years of a cash flow with present value (PV) given the interest rate $r$ is 

$$\textrm{FV}_t=\textrm{PV}\times (1+r)^t$$ 
"""

# ╔═╡ 36e6512e-a077-48ad-8fe8-70a1bd1bed93
md"""
## Present Value Example
"""

# ╔═╡ d82e3e70-a1bb-4860-8e1f-64a1cdda1aa5
@bind bttn_1 Button("Reset")

# ╔═╡ ce1e6bc3-3e22-4163-9c1f-f91976954376
begin
bttn_1
md"""
- Future Value (FV): $(@bind FV_1 Slider(0:0.25:200, default=100, show_value=true))
- Interest rate $r$ [% p.a.]: $(@bind r_1 Slider(0:0.25:10, default=2, show_value=true))
- Time $t$ [years]: $(@bind t_1 Slider(1:1:100, default=2, show_value=true))
"""
end

# ╔═╡ ef610fc4-d8e9-4fa2-a922-3af51d1b9a8f
Markdown.parse("
``\$\\textrm{PV} = \\frac{\\textrm{FV}_t}{(1+r)^t} = \\frac{\\\$ $FV_1}{(1+$(r_1/100))^{$t_1}}=\\\$$(roundmult(FV_1/(1+r_1/100)^t_1,1e-6))\$
``
")

# ╔═╡ a4f4cb87-c7e7-492c-8641-2829d9be0104
md"""
## Future Value Example
"""

# ╔═╡ eafc7e08-8490-460a-a52c-59ee862265ef
@bind bttn_2 Button("Reset")

# ╔═╡ ea9e0067-2a84-4209-a7b5-9f7b902c4a60
begin
bttn_2
md"""
- Present Value (FV): $(@bind PV_2 Slider(0:0.25:200, default=100, show_value=true))
- Interest rate $r$ [% p.a.]: $(@bind r_2 Slider(0:0.25:10, default=2, show_value=true))
- Time $t$ [years]: $(@bind t_2 Slider(1:1:100, default=2, show_value=true))
"""
end

# ╔═╡ 35de833e-6515-4747-a6b7-d6e069eee913
Markdown.parse("
``\$\\textrm{FV}_t = \\textrm{PV} \\times (1+r)^t = \\\$ $PV_2 \\times (1+$(r_2/100))^{$t_2}=\\\$$(roundmult(PV_2 * (1+r_2/100)^t_2,1e-6))\$
``
")

# ╔═╡ 78e9af96-4b63-4aa7-91f4-8f5c1b7cead1
md"""
# Present value of multiple cash flows
"""

# ╔═╡ a1b4981b-ca8a-49e4-ad2a-a1921a88f78e
md"""
- If there are multiple cash flows in the future in $t$=1, 2, 3, ... $T$ years from today, then we calculate the present value of these cash flows as follows.
  1. calculate the individual present values of each future cash flow: $PV_t$ for $t=1,...,T$
  2. sum up the individual present values: $PV_1+PV_2+...+PV_T$ 
"""

# ╔═╡ 9ef41bdc-54c5-499d-8577-f4b7cd0a3c1e
md"""
## Example
"""

# ╔═╡ d881d1ea-c070-46e9-aa8c-41f5f310b1d5
@bind bttn_3 Button("Reset")

# ╔═╡ 5601ba48-77a7-47be-8b33-bea1a4558852
begin
bttn_3
	md"""
	- Future Value (FV): $(@bind CF_3 Slider(0:0.25:200, default=100, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_3 Slider(0:0.25:10, default=2, show_value=true))
	- Time $t$ [years]: $(@bind T_3 NumberField(0:1:10,default=5))
	"""
end

# ╔═╡ 6c639bbb-9f32-4d1f-803f-1faf7c6c7ff2
begin
	TVec_3 = collect(1:1:T_3)
	CFVec_3 = CF_3.*collect(ones(T_3))
	# CFVec_3[end] += 1000
	PVVec_3 = CFVec_3./(1+r_3/100).^(TVec_3)
	PVTotal_3 = sum(PVVec_3)
	tmpStr3 = Vector{String}()
	for idx=1:length(CFVec_3)
	 	push!(tmpStr3,"$(CFVec_3[idx]) * 1/(1+$r_3%)^$idx=$(roundmult(PVVec_3[idx],1e-4))")
	end
	tmpStr31 = string(roundmult(PVVec_3[1],1e-4))
	for idx=2:length(CFVec_3)
		global tmpStr31 = tmpStr31 * " + " * string(roundmult(PVVec_3[idx],1e-4))
	end
	tmpStr31 = tmpStr31 * " = " * string(roundmult(PVTotal_3,1e-6))
	df_3 = DataFrame(Time=TVec_3, FutureValue=CFVec_3, PresentValue=PVVec_3, Calculation=tmpStr3)
end

# ╔═╡ 19a73b64-6d49-4ba6-8b97-f7743e78246d
md"""
Present Value = $(tmpStr31)
"""

# ╔═╡ c5374949-54aa-43b2-8aaa-d336f6bab239
md"""
# Perpetuities
"""

# ╔═╡ ffe4a1d1-2656-4db3-9659-b3b02ab7c3d7
md"""
- In the previous example, we calculated the present value of multiple future cash flows that were all equal to \$$CF_3 by calculating the present value of each individual future cash flow.
- Suppose now that we are paid \$$CF_3 each year forever.
- Calculating all individual cash flows is not feasible, of course.
"""

# ╔═╡ 2c9ae23c-8f2f-405a-aa9f-98a22b3c9ae0
md"""
## Types of perpetuities exist in reality
"""

# ╔═╡ 60dbef01-269c-4650-83c7-ac0f771f7d20
LocalResource("ConsolBondUS.png",:width => 1200) 

# ╔═╡ 9a7e2735-7648-4ebf-a52c-4c0e5bb6e91a
md"""
## Example
"""

# ╔═╡ 512a503c-5433-4f55-8541-86f4e752c128
@bind bttn_4 Button("Reset")

# ╔═╡ 56bd6aed-afd8-4317-a64a-a43a79951473
begin
bttn_4
	md"""
	- Future Value (FV): $(@bind CF_4 Slider(0:0.25:200, default=100, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_4 Slider(0:0.25:10, default=2, show_value=true))
	- Time $t$ [years]: $(@bind T_4 Slider(0:1:1000,default=5,show_value=true))
	"""
end

# ╔═╡ 887788ee-b94b-477e-89ba-96394d1c6cf2
begin
	TVec_4 = collect(1:1:T_4)
	CFVec_4 = CF_4.*collect(ones(T_4))
	PVVec_4 = CFVec_4./(1+r_4/100).^(TVec_4)
	PVTotal_4 = sum(PVVec_4)
	tmpStr4 = Vector{String}()
	for idx=1:length(CFVec_4)
	 	push!(tmpStr4,"$(CFVec_4[idx]) * 1/(1+$r_4%)^$idx=$(roundmult(PVVec_4[idx],1e-4))")
	end
	tmpStr41 = string(roundmult(PVVec_4[1],1e-4))
	for idx=2:length(CFVec_4)
		global tmpStr41 = tmpStr41 * " + " * string(roundmult(PVVec_4[idx],1e-4))
	end
	tmpStr41 = tmpStr41 * " = " * string(roundmult(PVTotal_4,1e-6))
	df_4 = DataFrame(Time=TVec_4, FutureValue=CFVec_4, PresentValue=PVVec_4)
	df_4
end

# ╔═╡ e0c58ed9-fe87-4fb2-a09d-b234f46dcd6a
Markdown.parse("
Present Value = \$ $(roundmult(PVTotal_4,1e-4))
- Compare the present value to 
\$\\frac{FV_{$(T_4)}}{r} = \\frac{$(CF_4)}{$(r_4/100)}= $(roundmult(CF_4/(r_4/100),1e-4))\$
")

# ╔═╡ a7a7c07b-f286-4afb-bd7d-3c9c2cc7dfc4
md"""
# Present Value of Perpetuity
"""

# ╔═╡ f36006b6-7e55-47b0-8515-0939b485ec81
md""" 
!!! important

The present value today (time $t=0$) of a perpetuity paying a dollar cash flow of $C$ forever is

$$\textrm{PV}=\frac{\textrm{C}}{r}$$ 

Time $\,t$    | 0   | 1  | 2 | 3 | ... |  
:------------ | :-- |:-- |:--|:--|:--
Cash Flow     | 0   | C  | C | C | C 

"""

# ╔═╡ d18f3d8c-3aee-44a7-aeac-382977ab338a
md"""
Time $\,t$    | 0   | 1  | 2 | 3 | ... |  
:------------ | :-- |:-- |:--|:--|:--
Cash Flow     | 0   | C  | C | C | C 
"""

# ╔═╡ fe7aa04e-009f-46ef-ac9d-c5037df85bba
md"""
# Growing Perpetuity
"""

# ╔═╡ c7b1b471-01be-4a67-892e-085f206cfc9a
md"""
## Example
"""

# ╔═╡ 73059c24-0be1-400d-ae1b-2c9464c0454e
md"""
- In the case of a perpetuity the cash flows are always the same.
- In a "growing perpetuity" the cash flows grow at a constant percentage rate $g$ **after** the first cash flow.
"""

# ╔═╡ d4da6743-18eb-4fda-a01b-7bd1623be748
@bind bttn_5 Button("Reset")

# ╔═╡ 0d8ba52d-237b-4876-a25f-11ec9e9b4360
begin
bttn_5
	md"""
	- Future Value (FV): $(@bind CF_5 Slider(0:0.25:200, default=100, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_5 Slider(0:0.25:10, default=2, show_value=true))
	- Growth rate $g$ [% p.a.]: $(@bind g_5 Slider(0:0.25:10, default=1, show_value=true))
	- Time $t$ [years]: $(@bind T_5 Slider(0:1:1000,default=5,show_value=true))
	"""
end

# ╔═╡ 25597529-94c2-4125-89aa-5b337d7a1967
begin
	TVec_5 = collect(1:1:T_5)
	CFVec_5 = CF_5.*collect(ones(T_5))
	for idx = 2:length(CFVec_5)
		CFVec_5[idx]=CFVec_5[idx-1]*(1+g_5/100)
	end
	PVVec_5 = CFVec_5./(1+r_5/100).^(TVec_5)
	PVTotal_5 = sum(PVVec_5)
	tmpStr5 = Vector{String}()
	for idx=1:length(CFVec_5)
	 	push!(tmpStr5,"$(CFVec_5[idx]) * 1/(1+$r_5%)^$idx=$(roundmult(PVVec_5[idx],1e-4))")
	end
	tmpStr51 = string(roundmult(PVVec_5[1],1e-4))
	for idx=2:length(CFVec_5)
		global tmpStr51 = tmpStr51 * " + " * string(roundmult(PVVec_5[idx],1e-4))
	end
	tmpStr51 = tmpStr51 * " = " * string(roundmult(PVTotal_5,1e-6))
	df_5 = DataFrame(Time=TVec_5, FutureValue=CFVec_5, PresentValue=PVVec_5)
	df_5
end

# ╔═╡ 6c576813-1065-42ed-b3fa-acd7dc7b3e3a
Markdown.parse("
Present Value = \$ $(roundmult(PVTotal_5,1e-4))
- Compare the present value to 
\$\\frac{FV_{$(T_5)}}{r-g} = \\frac{$(CF_5)}{$(r_5/100)-$(g_5/100)}= $(roundmult(CF_5/((r_5-g_5)/100),1e-4))\$
")

# ╔═╡ 250126f0-7050-4d89-b1b8-7e76312b900e
md"""
# Present Value of Growing Perpetuity
"""

# ╔═╡ 92685ca8-ec81-4631-a7ca-c9bf58f023c3
md""" 
!!! important

The present value today (time $t=0$) of a perpetuity paying a dollar cash flow of $C$ forever that grows at a constant percentage rate $g$ each period **after** the first cash flow is

$$\textrm{PV}=\frac{\textrm{C}}{r-g}$$ 

Time $\,t$    | 0   | 1  | 2 | 3 | 4 | ... |
:------------ | :-- |:-- |:--|:--|:--|:--|
Cash Flow     | 0   | $C$  | $C\times(1+g)$ | $C\times(1+g)^2$ | $C\times(1+g)^3$ |...

- *Note: We only consider cases where $g$ is less than $r$*

"""

# ╔═╡ 7f164f1c-4f2e-4aef-8544-c5ec6e10f43b
md"""
# Annuity
"""

# ╔═╡ 7a797bc5-0ae1-4015-8708-57145183fd9b
md"""
- An annuity pays a constant cash flow of $C$ at the end of each period for a specific number of periods.
- It is similar to a perpetuity, except that the cash flows stop after a certain number of periods.
"""

# ╔═╡ 8606c055-f522-4680-9da7-e314ac13664d
md"""
- [BlackRock Is Adding Annuities to 401(k)s](https://www.wsj.com/articles/blackrock-is-adding-annuities-to-401-k-s-11633512600?mod=hp_lead_pos7)
"""

# ╔═╡ 89dc6ad3-f92e-473b-b2f4-7cb27dc9ce28
md"""
- Assume that the interest rate is $r=5\%$ and we want to calculate the present value of a 10-year annuity with annual cash flows of \$50.
  - A 10-year annuity paying \$50, has the first cash flow at the end of the first year $t=1$, the next at the end of the second year $t=2$, ..., and on final cash flow at the end of year 30 ($t$=30).
- An annuity is the difference between two perpetuities. Why?
"""

# ╔═╡ f0d15768-4bb9-4826-ba3f-11907e41dc44
md"""
## Example
"""

# ╔═╡ 7a469a3d-de9d-4f8a-8612-2faece9125fd
let
	T=10
	dt = collect(1:1:T)
	CF = 50*ones(convert(Int64,T))
	tmpStr = L"\textrm{Present Value} = ?"
	bar(dt,CF,label="", ylim=(0,100), xlim=(0,T+5), xticks=collect(0
	:1:(T+5)), xlabel="Year", ylabel="Cash Flow", title="10-year Annuity")
	annotate!(5, 75, text(tmpStr, :blue, :left, 20))
end

# ╔═╡ 552d2dc5-1abc-4bef-b718-6b9ca615d814
md"""
##
"""

# ╔═╡ ea51df43-106b-49b8-a8bd-88bbc7a14735
let
	T=20
	dt = collect(1:1:T)
	CF = 50*ones(convert(Int64,T))
	tmpStr = L"\textrm{Present Value} = \frac{C}{r} = \frac{50}{0.05}"
	bar(dt,CF,label="", ylim=(0,100), xlim=(0,T-5), xticks=collect(0
	:1:(T-5)), xlabel="Year", ylabel="Cash Flow", title="Perpetuity")
	annotate!(4, 75, text(tmpStr, :blue, :left, 16))
end

# ╔═╡ f24cfd3f-14f2-480a-85ab-c31b0c80e364
md"""
##
"""

# ╔═╡ 9ac52810-5be5-4a2f-9f8a-68eb99ddb8f7
let
	T=20
	dt = collect(1:1:T)
	CF = -50*ones(convert(Int64,T))
	CF[1:10].=0
	tmpStr = L"\textrm{PV\ at\ year\ 10} = \frac{C}{r} = \frac{-50}{0.05}"
	tmpStr2 = L"\textrm{PV} = \frac{1}{(1+r)^{10}}\times\frac{C}{r} = \frac{1}{(1+0.05)^{10}} \times \frac{-50}{0.05}"
	bar(dt,CF,label="", ylim=(-100,0), xlim=(0,T-5), xticks=collect(0
	:1:(T-5)), xlabel="Year", ylabel="Cash Flow", title="Perpetuity starting in year 10")
	annotate!(3.5, -20, text(tmpStr, :blue, :left, 11))
	quiver!([10],[-20], quiver=([0],[-75]))
	annotate!(0.1, -75, text(tmpStr2, :blue, :left, 11))
	quiver!([10],[-97], quiver=([-5],[17]),c=:red)
	quiver!([5],[-80], quiver=([-4.85],[-18.5]),c=:red)
	
	# annotate!([10],[-50],"a")
end

# ╔═╡ 6fdd68d6-d108-438c-9411-67c879537fea
md"""
##
"""

# ╔═╡ dbb0b438-1809-4987-8be6-aac53bc4ca15
md"""
- Thus, the value of the 10-year annuity is the difference between the present values of the perpetuity starting today and the perpetuity starting in year 10.

$$\textrm{PV Annuity} = \textrm{PV of Perpetuity starting today} - \textrm{Perpetuity starting in year 10}$$


$$\left( \frac{50}{r} \right) - \left( \frac{50}{(1+r)^{10}}\times\frac{1}{r} \right)$$
$$\rightarrow \textrm{PV} = \left( \frac{50}{r} \right) \left(1 - \frac{1}{(1+r)^{10}} \right)$$

"""

# ╔═╡ 9e0a0706-e450-474a-9c3e-05c97b85bb6d
md"""
## Present Value of Annuity
"""

# ╔═╡ 3f7f5303-98ad-4d63-aff7-4a612dcc1bec
md""" 
!!! important

The present value today (time $t=0$) of an annuity paying a dollar cash flow of $C$ for $T$ years is

$$\textrm{PV} = \left( \frac{C}{r} \right) \left(1 - \frac{1}{(1+r)^{T}} \right)$$

Time $\,t$    | 0   | 1  | 2 | 3 | 4 | ... | T | T+1 | ...
:------------ | :-- |:-- |:--|:--|:--|:--|:--|:--|:--|
Cash Flow     | 0   | $C$  | $C$ | $C$ | $C$ |...|$C$|0|0

"""

# ╔═╡ a6929d69-a27d-4099-bd9f-987b70985748
md"""
# Compounding Frequencies
"""

# ╔═╡ d7bf6089-29cb-45cd-b7d4-9290bd131d94
md"""
- Consider again the Future Value formula and suppose $t=1$ year and assume that we compute the future value of \$100 after one year. In this example, we receive interest on the \$100 once after 1 year.

$$\textrm{FV}_1=\textrm{\$100}\times (1+r)^1$$ 
"""

# ╔═╡ bb4b8016-f668-4c52-aa9c-ef5fac1fa8f0
md"""
##
"""

# ╔═╡ 0ccb7979-3b75-495d-97a6-d97b4ff27eab
md"""
- Suppose now that we earn interest once after six months and again after another six months have passed.
- First, the future value after six months is
$$\textrm{FV}_{0.5}=\textrm{\$100}\times \left(1+\frac{r}{2}\right)$$ 
- Next, the future value after another six months have passed is
$$\textrm{FV}_{1}=\textrm{FV}_{0.5}\times\left(1+\frac{r}{2}\right)=\textrm{\$100}\times \left(1+\frac{r}{2}\right)^2$$ 
- When interest is computed twice per year, this is referred to semi-annual compounding.
"""

# ╔═╡ 954ebc2a-9073-461d-ab69-d219f2a323c2
md"""
##
"""

# ╔═╡ 5241f08a-2b3f-490f-a610-2f4eb4d7d22d
md"""
- Next, compute the future value of \$100 after 2 years with semi-annual compounding.
$$\textrm{FV}_{2}=\textrm{\$100}\times \left(1+\frac{r}{2}\right) \times \left(1+\frac{r}{2}\right) \times \left(1+\frac{r}{2}\right) \times \left(1+\frac{r}{2}\right)$$ 
"""

# ╔═╡ 031c076f-cb5a-4577-80cf-58c2500718ff
md"""
##
"""

# ╔═╡ 72b5d1a2-ddad-41d1-8b63-0e15d7869b1f
md"""
- In general after $T$ years and with semi-annual compounding, the future value of a dollar investment $PV$ is
$$FV_T = PV\times \left(1+\frac{r}{2} \right)^{2\times T}$$
"""

# ╔═╡ 220722c3-3d04-4085-ab95-5bf06253256f
md"""
##
"""

# ╔═╡ 6920a36c-9de4-45ac-9621-4a7bbb9095c1
md"""
- Consider now the **present** value of \$100 to be received in two years from now with semi-annual compounding
- Since we now know the Future value after $T=2$ years ($FV_2$), we rearrange the previous equation and solve for $PV$
$$PV=\frac{FV_2}{\left(1+\frac{r}{2}\right)^{2\times T}}$$
"""

# ╔═╡ d1aad779-4cbf-4d3a-a09b-e71e77ce38f3
md"""
- What if interest is compounded quarterly? Monthly? Daily?
- We can apply the same reasoning.
"""

# ╔═╡ 4af580d8-3b37-4956-9197-5e9cdd9f4d3e
md"""
## Present and Future Values with different compounding frequencies
"""

# ╔═╡ 63da993b-f86f-4bb2-8805-c05df8ceb857
md""" 
!!! important

- Let $r$ be the **annual** interest rate and let $T$ be the number of years.
- Let $PV$ be the the value today and $FV_T$ be the future value after $T$ years.
- Let $m$ be the compounding frequency
  - m=1 : Annual compounding
  - m=2 : Semi-annual compounding
  - m=4 : Quarterly compounding
  - m=12: Monthly compounding
"""

# ╔═╡ 39a6cb29-2916-4eaf-9439-2fe447702dcf
TwoColumn(
	md"""
	### Future Value
	$$FV_T = PV \times \left(1+\frac{r}{m}\right)^{m\times T}$$
	""",
	md"""
	### Present Value
	$$PV = FV_T \times \frac{1}{\left(1+\frac{r}{m}\right)^{m\times T}}$$
	"""
	
)

# ╔═╡ 2f5619f4-a1ba-4fbd-8a44-0bb998024b80
md"""
## Future Value Example
"""

# ╔═╡ 039bad7e-7e8b-4891-935a-6b33ca8fdab7
@bind bttn_6 Button("Reset")

# ╔═╡ 9dad18a2-93f3-4fdd-bbad-ff879a9f6e5b
begin
bttn_6
	md"""
	- Present Value (PV): $(@bind PV_6 Slider(0:0.25:200, default=100, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_6 Slider(0:0.25:10, default=2, show_value=true))
	- Compounding frequency $m$: $(@bind m_6 Select(["1","2","4","12"],default="2"))
	- Time $T$ [years]: $(@bind T_6 Slider(0:1:30,default=5,show_value=true))
	"""
end

# ╔═╡ 19139d1d-e8a9-4a7a-8409-3c46d90ec799
Markdown.parse("
``\$\\textrm{FV}_{$T_6} = \\textrm{PV} \\times \\left(1+\\frac{r}{m} \\right)^{m \\times T} =
\\\$ \\textrm{$PV_6} \\times \\left(1+\\frac{$r_6\\%}{$m_6} \\right)^{$m_6 \\times $T_6}=\\\$$(roundmult(PV_6*(1+r_6/(parse(Int64,m_6)*100))^(parse(Int64,m_6)*T_6),1e-6))\$
``")

# ╔═╡ 1628f265-12ef-41fc-b4c4-0218ea1c9001
md"""
## Present Value Example
"""

# ╔═╡ b7f06890-a3d2-4a79-aa07-62107acf4b08
@bind bttn_7 Button("Reset")

# ╔═╡ b27d3893-908f-41f8-969a-c3df976243ef
begin
bttn_7
	md"""
	- Future Value (FV): $(@bind FV_7 Slider(0:0.25:200, default=100, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_7 Slider(0:0.25:10, default=2, show_value=true))
	- Compounding frequency $m$: $(@bind m_7 Select(["1","2","4","12"],default="2"))
	- Time $T$ [years]: $(@bind T_7 Slider(0:1:30,default=5,show_value=true))
	"""
end

# ╔═╡ 576daa36-5271-480a-aabc-59b2f8ad7f9d
Markdown.parse("
``\$\\textrm{PV} = \\frac{ \\textrm{FV}_{$T_7}}{\\left(1+\\frac{r}{m} \\right)^{m \\times T}} =
\\frac{ \\\$ \\textrm{$FV_7}}{\\left(1+\\frac{$r_7\\%}{$m_7} \\right)^{$m_7 \\times $T_7}}=\\\$$(roundmult(FV_7/((1+r_7/(parse(Int64,m_7)*100))^(parse(Int64,m_7)*T_7)),1e-6))\$
``")

# ╔═╡ db973c76-2338-4c7d-be42-1c72b1d9e246
md"""
## Annuity formula with different compounding frequencies
- The annuity formula with different compounding frequencies becomes
**Present Value of Annuity**

The present value today (time $t=0$) of an annuity paying a dollar cash flow of $C$ for $T$ years when interest is compounded $m$ times per year is

$$\textrm{PV} = \left( \frac{C}{r/m} \right) \left(1 - \frac{1}{\left(1+\frac{r}{m}\right)^{m \times T}} \right)$$

"""

# ╔═╡ 0916378c-bcd9-4331-90d0-f5397483340f
md"""
## Example
"""

# ╔═╡ 2f9d2971-1ac3-4429-83da-4c9eaabc4c7f
@bind bttn_8 Button("Reset")

# ╔═╡ 0935ed2a-e1dc-4d7a-8f4d-76d965111e6e
begin
bttn_8
	md"""
	- Cash Flow (C): $(@bind C_8 Slider(0:0.25:200, default=50, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_8 Slider(0:0.25:10, default=2, show_value=true))
	- Compounding frequency $m$: $(@bind m_8 Select(["1","2","4","12"],default="2"))
	- Time $T$ [years]: $(@bind T_8 Slider(0:1:30,default=5,show_value=true))
	"""
end

# ╔═╡ c884a4b1-64fd-4bd4-8ebd-94c30d7f5d8f
Markdown.parse("
``\$\\textrm{PV} = \\left( \\frac{C}{r/m} \\right) \\left(1 - \\frac{1}{\\left(1+\\frac{r}{m}\\right)^{m \\times T}} \\right)
= \\left( \\frac{\\\$$C_8}{$(r_8/100)/$m_8} \\right) \\left(1 - \\frac{1}{\\left(1+\\frac{$(r_8/100)}{$m_8}\\right)^{$m_8 \\times $T_8}} \\right)
= $(roundmult(C_8/(r_8/(parse(Int64,m_8)*100))*(1-1/(1+r_8/(100*parse(Int64,m_8)))^(parse(Int64,m_8)*T_8)),1e-6))\$``")

# ╔═╡ 693388a9-981e-4345-b04f-f28c10818cb6
md"""
# Continuous Compounding
"""

# ╔═╡ 896724e2-942d-4889-bb0f-df5539a8c6aa
md"""
## Future Value and Present Value with continuous compounding
"""

# ╔═╡ 43b0a108-d7f7-4846-a5b8-d69c9273ca1f
md"""
- With continuous compounding, interest is compounded every instant.
- Mathematically, with continuous compounding the number of times that interest is compounded goes to infinity.
- Many of the models in Finance such as the Black-Scholes model use continuous compounding. This is done for tractability of the models.
"""

# ╔═╡ 3220bd19-a63d-4275-b690-cf749a81c2d7
md"""
## Present and Future Values with continuous compounding
"""

# ╔═╡ bb72ecef-8cab-4be4-9832-ff0613612303
md""" 
!!! important

- Let $r$ be the **annual** interest rate (continuously compounded) and let $T$ be the number of years.
- Let $PV$ be the the value today and $FV_T$ be the future value after $T$ years.
"""

# ╔═╡ bed8a48a-25a4-4896-b4f5-bd8b832f61ac
TwoColumn(
	md"""
	### Future Value
	$$FV_T = PV \times \exp(r\times T)$$
	""",
	md"""
	### Present Value
	$$PV = FV_T \times \exp(-r\times T)$$
	"""
	
)

# ╔═╡ be174887-523f-4a7a-9d69-e655dfaeb004
md"""
## Example
"""

# ╔═╡ 4d8c3380-b7b6-4404-8032-6a792e6262e5
@bind bttn_9 Button("Reset")

# ╔═╡ 412de1a3-8361-4b5b-a88a-165776106f49
begin
bttn_9
	md"""
	- Future Value (FV): $(@bind FV_9 Slider(0:0.25:200, default=50, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_9 Slider(0:0.25:10, default=2, show_value=true))
	- Time $T$ [years]: $(@bind T_9 Slider(0:0.25:30,default=5,show_value=true))
	"""
end

# ╔═╡ 1edaa850-3c80-4bc6-9622-d400b11cf5f5
Markdown.parse("
``\$\\textrm{PV} = FV_T \\times \\exp(-r \\times T) = \\\$ $FV_9 \\times \\exp(-$(r_9/100) \\times $T_9) = \\\$$(roundmult(FV_9*exp(-(r_9/100)*T_9),1e-6))
\$``")

# ╔═╡ 787d53ec-f09e-4e7c-b9ae-3d60bcce46bc
md"""
## Annuity formula with continuous compounding
"""

# ╔═╡ 8d2b39a5-8da6-4c42-b71b-321f629121f8
md"""
#### Present Value of Annuity with continuous compounding
The present value today (time $t=0$) of an annuity paying a (continuous) dollar cash flow of $C$ for $T$ years when interest is continuously compounded is

$$\textrm{PV} =  \frac{C}{\exp(r)-1} \times \left(1 - \exp(-r \times T) \right)$$

"""

# ╔═╡ 20f818e2-57a9-4554-90ad-55abe69c9638
md"""
## Example
"""

# ╔═╡ 299623b1-27df-4156-9cf4-55c95c074929
@bind bttn_10 Button("Reset")

# ╔═╡ bab3bfdc-737f-431b-b89f-3a34d5744c61
begin
bttn_10
	md"""
	- Cash Flow (C): $(@bind C_10 Slider(0:0.25:200, default=50, show_value=true))
	- Interest rate $r$ [% p.a.]: $(@bind r_10 Slider(0:0.25:10, default=2, show_value=true))
	- Time $T$ [years]: $(@bind T_10 Slider(0:0.25:30,default=5,show_value=true))
	"""
end

# ╔═╡ 4ec3c8fd-5d92-411c-a2d2-80d48a70128a
Markdown.parse("
``\$\\textrm{PV} = \\frac{C}{\\exp(-r T)} \\times \\left(1-\\exp(-r T) \\right) = \\frac{$C_10}{\\exp(-$(r_10/100)\\times $T_10)} \\times \\left(1-\\exp(-$(r_10/100)\\times $T_10)) \\right) = \\\$$(roundmult(C_10/(exp(r_10/100)-1)*(1-exp(-(r_10/100)*T_10)),1e-6))\$
``")

# ╔═╡ b49e25b7-26d3-4539-b3de-ccf02bb9398c
md"""
# Converting Compounding Frequencies
"""

# ╔═╡ 643f8034-fdc5-4577-aad8-29106ac8ec5e
md"""
- Suppose we are given an interest rate $r$ that is compounded $m$ times per year.
- We want to know what the equivalent interest rate is when interest is compounded $n$ times per year.
- To do this, we first find what an investment of \$1 is worth after one year given that the interest rate is $r$ and interest is compounded $m$ times per year.
- Then, to find the equivalent rate when interest rate is compounded $n$ times per year, we set the amount from the previous step equal to the amount we would have when interest is compounded $n$ times per year.
"""

# ╔═╡ 5091fc3d-ba6a-4892-9637-fa91b219b727
md"""
## Example
- Suppose, the semi-annually compounded interest rate is 4%.
- We want to find the equivalent continuously-compounded interest rate.
- Step 1:
  - A one dollar investment after one year has grown to: $$FV_1 = \$1 \times (1+\frac{r}{2})^{2\times 1}=\$1 \times (1+\frac{4\%}{2})^2=1.0816$$
- Step 2:
  - After one year, a one dollar investment with continuous-compounding at the interest rate $r_c$ has grown to: $$FV_1 = \$1 \times \exp(r_c\times 1)=\exp(r_c)$$
- Step 3:
  - Setting both equal, we can find $r_c$: 
$$\exp(r_c)=1.0816 \rightarrow r_c=\ln(1.0816) \rightarrow r_c = 7.8441\%$$
"""

# ╔═╡ 53c77ef1-899d-47c8-8a30-ea38380d1614
md"""
# Wrap-Up
"""

# ╔═╡ 670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
begin
	html"""
	<fieldset>      
        <legend>Goals for today</legend>      
		<br>
        <input type="checkbox" value="" checked=true>Calculate the present values of future cash flows, including bonds, annuities, perpetuities, and other arbitrary cash flows..<br><br>
	    <input type="checkbox" value="" checked=true>Understand different compounding frequencies and be able to convert between different compounding frequencies.<br><br>
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
Logging = "56ddb016-857b-54e1-b83d-db4d58db5568"
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
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

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
# ╟─9dba51e3-0738-40a1-96d8-f5583cdc5729
# ╟─731c88b4-7daf-480d-b163-7003a5fbd41f
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─6498b10d-bece-42bf-a32b-631224857753
# ╟─95db374b-b10d-4877-a38d-1d0ac45877c4
# ╟─f78c6a17-bee4-4fc1-bfee-a4788ebd6924
# ╟─c4832c71-4ce1-45d8-8bfe-c145efe5928d
# ╟─aac27a3c-e90a-437f-a563-f81d41c8d3f7
# ╟─13102a49-65b2-4b14-824c-412894cf2a95
# ╟─c7ffa30e-a4d9-4c3c-8495-f770dd70016d
# ╟─65c5b8fb-cb87-4404-9a28-df32c85966c6
# ╠═f3b7e23d-00dc-441c-97a2-575737b316df
# ╟─2293d075-6ea9-4757-9921-3251f9bab67b
# ╠═de693798-22a3-4e42-936a-372b3b67b77e
# ╟─46636299-a67a-438b-aedd-d31b13fb696d
# ╟─76e22a68-2f69-4715-adbd-c89c51d08415
# ╠═5ea2d792-1ddd-477c-b5e2-ac1a73d90499
# ╠═6de1c5cd-aa93-4124-b746-880b89d40a96
# ╠═0924235f-1e63-40ea-9b8f-b0625f68f8cf
# ╟─7e5f2316-212e-454a-a01f-d71197ce1993
# ╟─93319502-aafb-4b53-a887-e1dee962464d
# ╟─ac2c6913-cb1f-48cc-9fbe-c4bfa30f2153
# ╟─9a6ebe29-148a-481c-bda2-1b359bfc53f0
# ╟─78aa5d8d-c960-4898-b47c-caf5abf84ecd
# ╟─2ea69463-67cf-4205-8722-e3b81bf16c9e
# ╟─b32a9d56-3a51-42aa-b2cc-875111c9b81b
# ╟─5357fdfd-7691-485d-9672-867b77a01b36
# ╟─4f253073-5860-466d-8160-db83a0568cfe
# ╟─6325fbe2-53dd-43d4-8c88-c509ce018809
# ╟─ba1728fd-6fc9-4194-a85c-fcee35c32d1b
# ╟─a1ed3653-4a46-485e-bfc3-a78797d657f9
# ╟─d5ad6113-e839-40e0-a7d9-620167bdcd2f
# ╟─36e6512e-a077-48ad-8fe8-70a1bd1bed93
# ╟─ce1e6bc3-3e22-4163-9c1f-f91976954376
# ╟─d82e3e70-a1bb-4860-8e1f-64a1cdda1aa5
# ╟─ef610fc4-d8e9-4fa2-a922-3af51d1b9a8f
# ╟─a4f4cb87-c7e7-492c-8641-2829d9be0104
# ╟─ea9e0067-2a84-4209-a7b5-9f7b902c4a60
# ╟─eafc7e08-8490-460a-a52c-59ee862265ef
# ╟─35de833e-6515-4747-a6b7-d6e069eee913
# ╟─78e9af96-4b63-4aa7-91f4-8f5c1b7cead1
# ╟─a1b4981b-ca8a-49e4-ad2a-a1921a88f78e
# ╟─9ef41bdc-54c5-499d-8577-f4b7cd0a3c1e
# ╟─5601ba48-77a7-47be-8b33-bea1a4558852
# ╟─d881d1ea-c070-46e9-aa8c-41f5f310b1d5
# ╟─6c639bbb-9f32-4d1f-803f-1faf7c6c7ff2
# ╟─19a73b64-6d49-4ba6-8b97-f7743e78246d
# ╟─c5374949-54aa-43b2-8aaa-d336f6bab239
# ╟─ffe4a1d1-2656-4db3-9659-b3b02ab7c3d7
# ╟─2c9ae23c-8f2f-405a-aa9f-98a22b3c9ae0
# ╟─60dbef01-269c-4650-83c7-ac0f771f7d20
# ╟─9a7e2735-7648-4ebf-a52c-4c0e5bb6e91a
# ╟─56bd6aed-afd8-4317-a64a-a43a79951473
# ╟─512a503c-5433-4f55-8541-86f4e752c128
# ╟─887788ee-b94b-477e-89ba-96394d1c6cf2
# ╟─e0c58ed9-fe87-4fb2-a09d-b234f46dcd6a
# ╟─a7a7c07b-f286-4afb-bd7d-3c9c2cc7dfc4
# ╟─f36006b6-7e55-47b0-8515-0939b485ec81
# ╟─d18f3d8c-3aee-44a7-aeac-382977ab338a
# ╟─fe7aa04e-009f-46ef-ac9d-c5037df85bba
# ╟─c7b1b471-01be-4a67-892e-085f206cfc9a
# ╟─73059c24-0be1-400d-ae1b-2c9464c0454e
# ╟─0d8ba52d-237b-4876-a25f-11ec9e9b4360
# ╟─d4da6743-18eb-4fda-a01b-7bd1623be748
# ╟─25597529-94c2-4125-89aa-5b337d7a1967
# ╟─6c576813-1065-42ed-b3fa-acd7dc7b3e3a
# ╟─250126f0-7050-4d89-b1b8-7e76312b900e
# ╟─92685ca8-ec81-4631-a7ca-c9bf58f023c3
# ╟─7f164f1c-4f2e-4aef-8544-c5ec6e10f43b
# ╟─7a797bc5-0ae1-4015-8708-57145183fd9b
# ╟─8606c055-f522-4680-9da7-e314ac13664d
# ╟─89dc6ad3-f92e-473b-b2f4-7cb27dc9ce28
# ╟─f0d15768-4bb9-4826-ba3f-11907e41dc44
# ╟─7a469a3d-de9d-4f8a-8612-2faece9125fd
# ╟─552d2dc5-1abc-4bef-b718-6b9ca615d814
# ╟─ea51df43-106b-49b8-a8bd-88bbc7a14735
# ╟─f24cfd3f-14f2-480a-85ab-c31b0c80e364
# ╟─9ac52810-5be5-4a2f-9f8a-68eb99ddb8f7
# ╟─6fdd68d6-d108-438c-9411-67c879537fea
# ╟─dbb0b438-1809-4987-8be6-aac53bc4ca15
# ╟─9e0a0706-e450-474a-9c3e-05c97b85bb6d
# ╟─3f7f5303-98ad-4d63-aff7-4a612dcc1bec
# ╟─a6929d69-a27d-4099-bd9f-987b70985748
# ╟─d7bf6089-29cb-45cd-b7d4-9290bd131d94
# ╟─bb4b8016-f668-4c52-aa9c-ef5fac1fa8f0
# ╟─0ccb7979-3b75-495d-97a6-d97b4ff27eab
# ╟─954ebc2a-9073-461d-ab69-d219f2a323c2
# ╟─5241f08a-2b3f-490f-a610-2f4eb4d7d22d
# ╟─031c076f-cb5a-4577-80cf-58c2500718ff
# ╟─72b5d1a2-ddad-41d1-8b63-0e15d7869b1f
# ╟─220722c3-3d04-4085-ab95-5bf06253256f
# ╟─6920a36c-9de4-45ac-9621-4a7bbb9095c1
# ╟─d1aad779-4cbf-4d3a-a09b-e71e77ce38f3
# ╟─4af580d8-3b37-4956-9197-5e9cdd9f4d3e
# ╟─63da993b-f86f-4bb2-8805-c05df8ceb857
# ╟─39a6cb29-2916-4eaf-9439-2fe447702dcf
# ╟─2f5619f4-a1ba-4fbd-8a44-0bb998024b80
# ╟─9dad18a2-93f3-4fdd-bbad-ff879a9f6e5b
# ╟─039bad7e-7e8b-4891-935a-6b33ca8fdab7
# ╟─19139d1d-e8a9-4a7a-8409-3c46d90ec799
# ╟─1628f265-12ef-41fc-b4c4-0218ea1c9001
# ╟─b27d3893-908f-41f8-969a-c3df976243ef
# ╟─b7f06890-a3d2-4a79-aa07-62107acf4b08
# ╟─576daa36-5271-480a-aabc-59b2f8ad7f9d
# ╟─db973c76-2338-4c7d-be42-1c72b1d9e246
# ╟─0916378c-bcd9-4331-90d0-f5397483340f
# ╟─0935ed2a-e1dc-4d7a-8f4d-76d965111e6e
# ╟─2f9d2971-1ac3-4429-83da-4c9eaabc4c7f
# ╟─c884a4b1-64fd-4bd4-8ebd-94c30d7f5d8f
# ╟─693388a9-981e-4345-b04f-f28c10818cb6
# ╟─896724e2-942d-4889-bb0f-df5539a8c6aa
# ╟─43b0a108-d7f7-4846-a5b8-d69c9273ca1f
# ╟─3220bd19-a63d-4275-b690-cf749a81c2d7
# ╟─bb72ecef-8cab-4be4-9832-ff0613612303
# ╟─bed8a48a-25a4-4896-b4f5-bd8b832f61ac
# ╟─be174887-523f-4a7a-9d69-e655dfaeb004
# ╟─412de1a3-8361-4b5b-a88a-165776106f49
# ╟─4d8c3380-b7b6-4404-8032-6a792e6262e5
# ╟─1edaa850-3c80-4bc6-9622-d400b11cf5f5
# ╟─787d53ec-f09e-4e7c-b9ae-3d60bcce46bc
# ╟─8d2b39a5-8da6-4c42-b71b-321f629121f8
# ╟─20f818e2-57a9-4554-90ad-55abe69c9638
# ╟─bab3bfdc-737f-431b-b89f-3a34d5744c61
# ╟─299623b1-27df-4156-9cf4-55c95c074929
# ╟─4ec3c8fd-5d92-411c-a2d2-80d48a70128a
# ╟─b49e25b7-26d3-4539-b3de-ccf02bb9398c
# ╟─643f8034-fdc5-4577-aad8-29106ac8ec5e
# ╟─5091fc3d-ba6a-4892-9637-fa91b219b727
# ╟─53c77ef1-899d-47c8-8a30-ea38380d1614
# ╟─670e45a3-9d28-47ae-a6b6-a1b1c67a0a4c
# ╟─2ee2c328-5ebe-488e-94a9-2fce2200484c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
