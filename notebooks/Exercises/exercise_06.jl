### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ d160a115-56ed-4598-998e-255b82ec37f9
begin
	using DataFrames, Statistics, LaTeXStrings, HypertextLiteral, PlutoUI,Printf
#------------------------------------------------------------------------------
"""
    printmat([fh::IO],x...;colNames=[],rowNames=[],
             width=10,prec=3,NoPrinting=false,StringFmt="",cell00="")
Print all elements of a matrix (or several) with predefined formatting. It can also handle
OffsetArrays. StringFmt = "csv" prints using a csv format.
# Input
- `fh::IO`:            (optional) file handle. If not supplied, prints to screen
- `x::Array(s)`:       (of numbers, dates, strings, ...) to print
- `colNames::Array`:   of strings with column headers
- `rowNames::Array`:   of strings with row labels
- `width::Int`:        (keyword) scalar, minimum width of printed cells
- `prec::Int`:         (keyword) scalar, precision of printed cells
- `NoPrinting::Bool`:  (keyword) bool, true: no printing, just return formatted string [false]
- `StringFmt::String`: (keyword) string, "", "csv"
- `cell00::String`:    (keyword) string, for row 0, column 0
# Output
- str         (if NoPrinting) string, (otherwise nothing)
# Examples
```
x = [11 12;21 22]
printmat(x)
```
```
x = [1 "ab"; Date(2018,10,7) 3.14]
printmat(x,width=20,colNames=["col 1","col 2"])
```
```
printmat([11,12],[21,22])
```
Can also call as
```
opt = Dict(:rowNames=>["1";"4"],:width=>10,:prec=>3,:NoPrinting=>false,:StringFmt=>"")
printmat(x;colNames=["a","b"],opt...)     #notice ; and ...
```
(not all keywords are needed)
# Requires
- fmtNumPs
# Notice
- The prefixN and suffixN could potentially be made function inputs. This would allow
a fairly flexible way to format tables.
Paul.Soderlind@unisg.ch
"""
function printmat(fh::IO,x...;colNames=[],rowNames=[],
                  width=10,prec=3,NoPrinting=false,StringFmt="",cell00="")

  isempty(x) && return nothing                         #do nothing is isempty(x)

  typeTestQ = any(!=(eltype(x[1])),[eltype(z) for z in x])  #test if eltype(x[i]) differs
  if typeTestQ                                      #create matrix from tuple created by x...
    x = hcat(Matrix{Any}(hcat(x[1])),x[2:end]...)   #preserving types of x[i]
  else
    x = hcat(x...)
  end

  (m,n) = (size(x,1),size(x,2))

  (length(rowNames) == 1 < m) && (rowNames = [string(rowNames[1],i) for i = 1:m])  #"ri"
  (length(colNames) == 1 < n) && (colNames = [string(colNames[1],i) for i = 1:n])  #"ci"

  if StringFmt == "csv"
    (prefixN,suffixN)   = (fill("",n),vcat(fill(",",n-1),""))  #prefix and suffix for column 1:n
    (prefixC0,suffixC0) = ("",",")                             #prefix and suffix for column 0
  else
    (prefixN,suffixN) = (fill("",n),fill("",n))
    (prefixC0,suffixC0) = ("","")
  end

  if length(rowNames) == 0                         #width of column 0 (cell00 and rowNames)
    col0Width = 0
  else
    col0Width = maximum(length,vcat(cell00,rowNames)) + length(prefixC0) + length(suffixC0)
  end

  colWidth = [width + length(prefixN[j]) + length(suffixN[j]) for j=1:n]  #widths of column 1:n

  iob = IOBuffer()

  if !isempty(colNames)                                #print (cell00,colNames), if any
    !isempty(cell00) ?  txt0 = string(prefixC0,cell00,suffixC0) : txt0 = ""
    print(iob,rpad(txt0,col0Width))
    for j = 1:n                                #loop over columns
      print(iob,lpad(string(prefixN[j],colNames[j],suffixN[j]),colWidth[j]))
    end
    print(iob,"\n")
  end
                                                       #print rowNames and x
  (i0,j0) = (1 - first(axes(x,1)),1 - first(axes(x,2)))   #i+i0,j+j0 give traditional indices
  for i in axes(x,1)                           #loop over rows
    !isempty(rowNames) && print(iob,rpad(string(prefixC0,rowNames[i+i0],suffixC0),col0Width))
    for j in axes(x,2)                         #loop over columns
      print(iob,fmtNumPs(x[i,j],width,prec,"right",prefix=prefixN[j+j0],suffix=suffixN[j+j0]))
    end
    print(iob,"\n")
  end
  str = String(take!(iob))

  if NoPrinting                              #no printing, just return str
    return str
  else                                       #print, return nothing
    print(fh,str,"\n")
    return nothing
  end

end
                        #when fh is not supplied: printing to screen
printmat(x...;colNames=[],rowNames=[],width=10,prec=3,NoPrinting=false,StringFmt="",cell00="") =
    printmat(stdout::IO,x...;colNames,rowNames,width,prec,NoPrinting,StringFmt,cell00)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    printlnPs([fh::IO],z...;width=10,prec=3)
Subsitute for println, with predefined formatting.
# Input
- `fh::IO`:    (optional) file handle. If not supplied, prints to screen
- `z::String`: string, numbers and arrays to print
Paul.Soderlind@unisg.ch
"""
function printlnPs(fh::IO,z...;width=10,prec=3)

  for x in z                              #loop over inputs in z...
    if isa(x,AbstractArray)
      iob = IOBuffer()
      for i = 1:length(x)
        print(iob,fmtNumPs(x[i],width,prec,"right"))
      end
      print(fh,String(take!(iob)))
    else
      print(fh,fmtNumPs(x,width,prec,"right"))
    end
  end

  print(fh,"\n")

end
                      #when fh is not supplied: printing to screen
printlnPs(z...;width=10,prec=3) = printlnPs(stdout::IO,z...;width,prec)
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPs(z,width=10,prec=2,justify="right";prefix="",suffix="")
Create a formatted string of a float (eg, "%10.4f"), nothing (""),
while other values are passed through. Strings are right (or left) justified
and can optionally be given prefix and suffix (eg, ",")
# Notice
- With prec > 0 and isa(z,Integer), then the string is padded with 1+prec spaces
to align with the printing of floats with the same prec.
# Requires
- Printf (for 1.6-), fmtNumPsC (for < 1.6)
"""
function fmtNumPs(z,width=10,prec=2,justify="right";prefix="",suffix="")

  isa(z,Bool) && (z = convert(Int,z))             #Bool -> Int

  if isa(z,AbstractFloat)                         #example: 101.0234, prec=3
    if VERSION < v"1.6-"
      fmt    = "%$(width).$(prec)f"
      zRound = round(z,digits=prec)
      strLR  = fmtNumPsC(fmt,zRound)                #C fallback solution
    else
      fmt   = Printf.Format("%$(width).$(prec)f")
      strLR = Printf.format(fmt,z)
    end
  elseif isa(z,Nothing)
    strLR = ""
  elseif isa(z,Integer) && prec > 0               #integer followed by (1+prec spaces)
    strLR = string(z," "^(1+prec))
  else                                            #Int, String, Date, Missing, etc
    strLR = string(z)
  end

  strLR = string(prefix,strLR,suffix)

  if justify == "left"                            #justification
    strLR = rpad(strLR,width+length(prefix)+length(suffix))
  else
    strLR = lpad(strLR,width+length(prefix)+length(suffix))
  end

  return strLR

end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
"""
    fmtNumPsC(fmt,z)
c fallback solution for formatting of floating point number. Used if VERSION < v"1.6-"
"""
function fmtNumPsC(fmt,z)                           #c fallback solution
  if ismissing(z) || isnan(z) || isinf(z)    #asprintf does not work for these cases
    str = string(z)
  else
    strp = Ref{Ptr{Cchar}}(0)
    len = ccall(:asprintf,Cint,(Ptr{Ptr{Cchar}},Cstring,Cdouble...),strp,fmt,z)
    str = unsafe_string(strp[],len)
    Libc.free(strp[])
  end
  return str
end
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
function printblue(x...)
  foreach(z->printstyled(z,color=:blue,bold=true),x)
  print("\n")
end
function printred(x...)
  foreach(z->printstyled(z,color=:red,bold=true),x)
  print("\n")
end
function printmagenta(x...)
  foreach(z->printstyled(z,color=:magenta,bold=true),x)
  print("\n")
end
function printyellow(x...)
  foreach(z->printstyled(z,color=:yellow,bold=true),x)
  print("\n")
end
#------------------------------------------------------------------------------

	#helper functions
	#round to digits, e.g. 6 digits then prec=1e-6
	roundmult(val, prec) = (inv_prec = 1 / prec; round(val * inv_prec) / inv_prec); 
	display("")
end

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
	<p align=center style="font-size:25px; font-family:family:Georgia"> <b> Exercise 06
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

# ╔═╡ a04b63e4-9c71-406e-b185-a27c7083371a
md"""
# Question 1
"""

# ╔═╡ e2b51a3d-1ea0-47cc-882f-808c82bed745
begin
	F2 = 1000
	c2 = 5
	y2 = 7
	T2 = 10
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
	
	deltaY22 = 0.5
	display("")
end

# ╔═╡ 24213af7-4c78-4a96-baf6-db05d2087e08
Markdown.parse("
> - Consider a semi-annual bond with time-to-maturity ``T=$T2`` years, face value ``F=$F2``, coupon rate ``c=$c2``%, and yield-to-maturity ``y=$y2``%. 
> 1. Calculate the convexity ``\\textrm{CX}`` of this bond using the approximate convexity formula (use ``\\Delta y=$(deltaY2)``%).
> 2. Calculate the modified duration ``\\textrm{MD}`` of this bond using the approximate modified duration formula (use ``\\Delta y=$(deltaY2)``%).
> 3. Calculate the percent change in the bond price using convexity and modified duration to a yield change of $(deltaY22)%.
")

# ╔═╡ 43fccccf-3432-408b-9b2c-cd48481cdb54
md"""
## Solution
"""

# ╔═╡ 0ac1ccd8-f726-4a95-8978-5069b553e90e
Markdown.parse("
__Part 1__
- Recall that the convexity can be calculated using the approximation 

``\$\\textrm{CX} = \\frac{P(y+\\Delta y)+P(y-\\Delta y)-2\\times P(y)}{(\\Delta y)^2} \\times \\frac{1}{P(y)}\$``

- We start by selecting the yield change ``\\Delta y=$deltaY2``%
- First, we calculate the bond price ``P(y)``
``\$ P(y) = \\frac{C}{y/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2,1e-4))\$``

- Next, using ``\\Delta y=$deltaY2``% 
``\$ P(y+\\Delta y) = \\frac{C}{(y+\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2plus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2plus\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2plus\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2plus,1e-4))\$``

- Similarly,
``\$ P(y-\\Delta y) = \\frac{C}{(y-\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C2}{$y2minus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y2minus\\%}{2}\\right)^{2\\times $T2}} \\right) + \\frac{$F2}{\\left(1+\\frac{$y2minus\\%}{2}\\right)^{2\\times $T2}} = $(roundmult(P2minus,1e-4))\$``

- Thus,
``\$\\textrm{CX} = \\frac{$(roundmult(P2plus,1e-4))+$(roundmult(P2minus,1e-4))-2\\times $(roundmult(P2,1e-4))}{($(roundmult(deltaY2,1e-4)))^2} \\times \\frac{1}{$(roundmult(P2,1e-4))}=$(roundmult(CX2,1e-6))
\$``

__Part 2__
- Recall that the modified duration of the bond is 

``\$MD(y) = - \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{2\\times \\Delta y} \\times \\frac{1}{P(y)}\$``

``\$MD(y) = - \\frac{$(roundmult(P2plus,1e-4))-$(roundmult(P2minus,1e-4))}{2\\times $(roundmult(deltaY2,1e-4))\\%} \\times \\frac{1}{$(roundmult(P2,1e-4))}=$(roundmult(MD2,1e-6))\$``

__Part 3__
- Thus, when the yield increases from ``y=$y2``% to ``y=$(y2+deltaY22)``%, the approximate percent change in the bond price is
``\$ \\frac{\\Delta P}{P} = -MD(y) \\times \\Delta y + \\frac{1}{2} \\times \\textrm{CX} \\times (\\Delta y)^2\$``

``\$ \\frac{\\Delta P}{P} = $(-roundmult(MD2,1e-6)) \\times 0.005 + \\frac{1}{2} \\times $(roundmult(CX2,1e-6)) \\times (0.005)^2 = $(roundmult(-MD2*0.005+0.5*CX2*0.005^2,1e-6))=$(roundmult(100*(-MD2*0.005+0.5*CX2*0.005^2),1e-4))\\%\$``

")

# ╔═╡ 3b40838c-875f-42aa-b915-39ee0e874a77
md"""
##
"""

# ╔═╡ e00a8ff6-a0f2-45ec-af54-ef8b0541b8ea
md"""
# Question 2
"""

# ╔═╡ 9b77fac9-c667-4c48-99dd-ef2f2e726c9e
begin
	matVec4 = [2,4,6,8,10]
	yVec4 = [1,2,3,4,5]
	fVec4 = [75,50,25,120,1100]
	pVec4 = 100 ./ (1 .+ yVec4/100).^matVec4
	nB4 = fVec4./100
	MD4 = matVec4 ./ (1 .+ (yVec4./100) )
	CX4 = (matVec4.^2 .+ matVec4) ./ (1 .+ (yVec4./100) ).^2
	Pb4 = sum((nB4 .* pVec4))
	wB4 = (nB4 .* pVec4) ./ Pb4
	df4 = DataFrame(Bond=["H","I","J","K","L"],Maturity=matVec4,Yield=yVec4,FaceValue=fVec4,PricePer100=pVec4,nB=nB4, CX=CX4, Pb =Pb4, wb=wB4, wB_CX=wB4.*CX4)
	display("")
end

# ╔═╡ 5617fb73-7042-4896-9b60-d5aa236faa79
md"""
- Suppose that you own a portfolio of zero-coupon bonds. All yields are annually compounded. Calculate the convexity of the portfolio.

Bond   |  Maturity     | Yield        | Face value 
:------|:--------------|:-------------|:-------------
H      | $(matVec4[1]) | $(yVec4[1])% | $(fVec4[1])
I      | $(matVec4[2]) | $(yVec4[2])% | $(fVec4[2])
J      | $(matVec4[3]) | $(yVec4[3])% | $(fVec4[3])
K      | $(matVec4[4]) | $(yVec4[4])% | $(fVec4[4])
L      | $(matVec4[5]) | $(yVec4[5])% | $(fVec4[5])

"""

# ╔═╡ fe60bdf9-221b-4a36-afd2-479d2be5a2cd
md"""
## Solution
"""

# ╔═╡ 976c23bb-d905-4f47-9688-aa1da4963d57
md"""
- First, calculate the the prices of the zero coupon bonds per \$100 face value.
- Recall, that the price of a $T$-year maturity zero-coupon bond with yield $y_T$ (annually compounded) is given by

$$P_T = \frac{100}{(1+y_T)^T}$$


"""

# ╔═╡ c2e54dd7-fd08-4030-99cf-9eb78dfddeb3
with_terminal() do
	printmat(pVec4,width=20,colNames=["Price (per 100 par)"], rowNames=["H","I","J","K","L"])
end

# ╔═╡ 8ad780ba-5ce9-4570-bdc3-392306c1277c
md"""
- Next, calculate the number of units $n_b$ for each bond $b$ in the portfolio.
- The number of bonds is simply the actual face value divided by 100 face value (which we used to calculate the bond price).
"""

# ╔═╡ f80a7bff-7358-449d-8281-d3574aa7c1ef
with_terminal() do
	printmat(nB4,width=20,colNames=["n_b"], rowNames=["H","I","J","K","L"])
end

# ╔═╡ f30e1fd9-f6c1-47dd-87fd-ad6c2e020725
md"""
- Next, calculate the convexities of the zero-coupon bonds.
- Recall that for a zero-coupon bond with time-to-maturity $T$ and yield-to-maturity $y$ (**annually compounded**), the convexity is

$$\textrm{CX} = \frac{T^2+T}{(1+y)^2}$$


"""

# ╔═╡ c95cf2f4-6cc1-4977-b574-b12fef7bb37d
with_terminal() do
	printmat(CX4,width=20,colNames=["CX"], rowNames=["H","I","J","K","L"])
end

# ╔═╡ 7e9f4f5f-7680-456e-90f6-f506634a43d0
md"""
- Next, calculate the total value of the bond portfolio.
- The value of the bond portfolio $P_{\textrm{Portfolio}}$ is the sum of the values of the positions in the individual bonds. The position in bond $b$ is worth the number of units times the bond price, i.e. $n_b \times P_b$.

- The portfolio value is \$$(roundmult(Pb4,1e-2)).
"""

# ╔═╡ 84a5444c-701a-47f1-bc01-b37f583470ae
md"""
- Next, calculate the portfolio weights

$$w_b = \frac{n_b\times P_b}{P_{\textrm{Portfolio}}}$$

"""

# ╔═╡ 2b0a344f-cf53-40a5-af39-0781d189d3ca
with_terminal() do
	printmat(wB4,width=20,colNames=["w"], rowNames=["H","I","J","K","L"])
end

# ╔═╡ 37e907d1-84f3-4594-a74a-6d68277a3cb6
md"""
- To summarize:
"""

# ╔═╡ 14a67d78-db7c-4370-ad5c-16d67dbdce61
df4

# ╔═╡ f78ddce5-b37c-4e1c-8d93-db927ffdf322
md"""
- As the last step, we compute the convexity of the portfolio $CX_{\textrm{Portfolio}}$

$$CX_{\textrm{Portfolio}} = w_1 \times CX_1 + w_2 \times CX_2 + \ldots + w_B \times CX_B$$
"""

# ╔═╡ 3789e51d-907c-43ce-8aa0-d90e5497d8c1
md"""
- The solution is:
"""

# ╔═╡ 8588e307-38c4-484c-aae0-325f4c3ca14c
Markdown.parse("
``\$CX_{\\textrm{Portfolio}} = $(roundmult(df4.wB_CX[1],1e-4)) + $(roundmult(df4.wB_CX[2],1e-4)) + $(roundmult(df4.wB_CX[3],1e-4)) + $(roundmult(df4.wB_CX[4],1e-4)) + $(roundmult(df4.wB_CX[5],1e-4))\$``

``\$CX_{\\textrm{Portfolio}} = $(roundmult(sum(df4.wB_CX),1e-6))\$``
")

# ╔═╡ 29856d79-4d92-4d4b-b9d6-168cf3126c2f
md"""
# Question 3
"""

# ╔═╡ c7c54376-b9a4-4772-bb6f-4bed11333ddd
begin
	F3 = 1000
	c3 = 5
	y3 = 7
	T3 = 10
	C3 = c3/200*F2
	dt3vec = 0.5:0.5:T3
	deltaY3 = 0.2
	y3plus  = y3 + deltaY3
	y3minus = y3 - deltaY3
	C3Vec = C3 .* ones(length(dt3vec))
	C3Vec[end]=F3+C3
	PV3Vec = C3Vec ./ (1 .+ y3/200 ).^(2 .* dt3vec)
	P3 = sum(PV3Vec)

	PV3Vecplus = C3Vec ./ (1 .+ y3plus/200 ).^(2 .* dt3vec)
	P3plus = sum(PV3Vecplus)
	PV3Vecminus = C3Vec ./ (1 .+ y3minus/200 ).^(2 .* dt3vec)
	P3minus = sum(PV3Vecminus)
	MD3 = -(P3plus-P3minus)/(2*deltaY3/100*P3)
	CX3 = (P3plus + P3minus - 2*P3)/(deltaY3/100)^2*1/P3
	
	deltaY33 = 0.5
	display("")
end

# ╔═╡ ab8da88e-f85f-4173-8422-c25839b5f393
Markdown.parse("
> - Consider a semi-annual bond with time-to-maturity ``T=$T3`` years, face value ``F=$F3``, coupon rate ``c=$c3``%, and yield-to-maturity ``y=$y3``%. 
> 1. Calculate the convexity ``\\textrm{CX}`` of this bond using the approximate convexity formula (use ``\\Delta y=$(deltaY3)``%).
> 2. Calculate the modified duration ``\\textrm{MD}`` of this bond using the approximate modified duration formula (use ``\\Delta y=$(deltaY3)``%).
> 3. Calculate the percent change in the bond price using convexity and modified duration to a yield change of $(deltaY33)%.
")

# ╔═╡ ff9585b6-882f-40c3-a47f-16c3c964c81e
Markdown.parse("
__Part 1__
- Recall that the convexity can be calculated using the approximation 

``\$\\textrm{CX} = \\frac{P(y+\\Delta y)+P(y-\\Delta y)-2\\times P(y)}{(\\Delta y)^2} \\times \\frac{1}{P(y)}\$``

- We start by selecting the yield change ``\\Delta y=$deltaY3``%
- First, we calculate the bond price ``P(y)``
``\$ P(y) = \\frac{C}{y/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y}{2}\\right)^{2\\times T}}
=\\frac{$C3}{$y3\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y3\\%}{2}\\right)^{2\\times $T3}} \\right) + \\frac{$F3}{\\left(1+\\frac{$y3\\%}{2}\\right)^{2\\times $T3}} = $(roundmult(P3,1e-4))\$``

- Next, using ``\\Delta y=$deltaY3``% 
``\$ P(y+\\Delta y) = \\frac{C}{(y+\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y+\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C3}{$y3plus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y3plus\\%}{2}\\right)^{2\\times $T3}} \\right) + \\frac{$F3}{\\left(1+\\frac{$y3plus\\%}{2}\\right)^{2\\times $T3}} = $(roundmult(P3plus,1e-4))\$``

- Similarly,
``\$ P(y-\\Delta y) = \\frac{C}{(y-\\Delta y)/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}} \\right) + \\frac{F}{\\left(1+\\frac{y-\\Delta y}{2}\\right)^{2\\times T}}
=\\frac{$C3}{$y3minus\\%/2} \\times \\left(1-\\frac{1}{\\left(1+\\frac{$y3minus\\%}{2}\\right)^{2\\times $T3}} \\right) + \\frac{$F3}{\\left(1+\\frac{$y3minus\\%}{2}\\right)^{2\\times $T3}} = $(roundmult(P3minus,1e-4))\$``

- Thus,
``\$\\textrm{CX} = \\frac{$(roundmult(P3plus,1e-4))+$(roundmult(P3minus,1e-4))-2\\times $(roundmult(P3,1e-4))}{($(roundmult(deltaY3,1e-4)))^2} \\times \\frac{1}{$(roundmult(P3,1e-4))}=$(roundmult(CX3,1e-6))
\$``

__Part 2__
- Recall that the modified duration of the bond is 

``\$MD(y) = - \\frac{P(y+\\Delta y)-P(y-\\Delta y)}{2\\times \\Delta y} \\times \\frac{1}{P(y)}\$``

``\$MD(y) = - \\frac{$(roundmult(P3plus,1e-4))-$(roundmult(P3minus,1e-4))}{2\\times $(roundmult(deltaY3,1e-4))\\%} \\times \\frac{1}{$(roundmult(P3,1e-4))}=$(roundmult(MD3,1e-6))\$``

__Part 3__
- Thus, when the yield increases from ``y=$y3``% to ``y=$(y3+deltaY33)``%, the approximate percent change in the bond price is
``\$ \\frac{\\Delta P}{P} = -MD(y) \\times \\Delta y + \\frac{1}{2} \\times \\textrm{CX} \\times (\\Delta y)^2\$``

``\$ \\frac{\\Delta P}{P} = $(-roundmult(MD3,1e-6)) \\times 0.005 + \\frac{1}{2} \\times $(roundmult(CX3,1e-6)) \\times (0.005)^2 = $(roundmult(-MD3*0.005+0.5*CX3*0.005^2,1e-6))=$(roundmult(100*(-MD3*0.005+0.5*CX3*0.005^2),1e-4))\\%\$``

")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
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
# ╟─a5de5746-3df0-45b4-a62c-3daf36f015a5
# ╟─3eeb383c-7e46-46c9-8786-ab924b475d45
# ╟─a04b63e4-9c71-406e-b185-a27c7083371a
# ╟─e2b51a3d-1ea0-47cc-882f-808c82bed745
# ╟─24213af7-4c78-4a96-baf6-db05d2087e08
# ╟─43fccccf-3432-408b-9b2c-cd48481cdb54
# ╟─0ac1ccd8-f726-4a95-8978-5069b553e90e
# ╟─3b40838c-875f-42aa-b915-39ee0e874a77
# ╟─e00a8ff6-a0f2-45ec-af54-ef8b0541b8ea
# ╟─5617fb73-7042-4896-9b60-d5aa236faa79
# ╟─9b77fac9-c667-4c48-99dd-ef2f2e726c9e
# ╟─fe60bdf9-221b-4a36-afd2-479d2be5a2cd
# ╟─976c23bb-d905-4f47-9688-aa1da4963d57
# ╟─c2e54dd7-fd08-4030-99cf-9eb78dfddeb3
# ╟─8ad780ba-5ce9-4570-bdc3-392306c1277c
# ╟─f80a7bff-7358-449d-8281-d3574aa7c1ef
# ╟─f30e1fd9-f6c1-47dd-87fd-ad6c2e020725
# ╟─c95cf2f4-6cc1-4977-b574-b12fef7bb37d
# ╟─7e9f4f5f-7680-456e-90f6-f506634a43d0
# ╟─84a5444c-701a-47f1-bc01-b37f583470ae
# ╟─2b0a344f-cf53-40a5-af39-0781d189d3ca
# ╟─37e907d1-84f3-4594-a74a-6d68277a3cb6
# ╟─14a67d78-db7c-4370-ad5c-16d67dbdce61
# ╟─f78ddce5-b37c-4e1c-8d93-db927ffdf322
# ╟─3789e51d-907c-43ce-8aa0-d90e5497d8c1
# ╟─8588e307-38c4-484c-aae0-325f4c3ca14c
# ╟─29856d79-4d92-4d4b-b9d6-168cf3126c2f
# ╟─c7c54376-b9a4-4772-bb6f-4bed11333ddd
# ╟─ab8da88e-f85f-4173-8422-c25839b5f393
# ╟─ff9585b6-882f-40c3-a47f-16c3c964c81e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
