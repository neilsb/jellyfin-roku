function decode83 (str as string) as integer
  digitCharacters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~"
  value = 0
    for i = 0 to len(str) - 1
        c = Mid(str, i + 1, 1)
        digit = Instr(0, digitCharacters, c) - 1
        value = value * 83 + digit
    end for

    return value

end function



function isBlurhashValid  (blurhash as string) as boolean

  if blurhash = invalid or len(blurhash) < 6 then
     print "The blurhash string must be at least 6 characters"
    return false
  end if

   sizeFlag = decode83(Mid(blurhash, 0, 1))
   numY = Fix(sizeFlag / 9) + 1
   numX = (sizeFlag mod 9) + 1

  if len(blurhash) <> 4 + 2 * numX * numY then
    print "blurhash length mismatch: length is " + Str(len(blurhash)) + " but it should be " + Str(4 + 2 * numX * numY)
    return false
  end if

  return true
end function


function sRGBToLinear (value as float)
  v = value / 255
  
  if (v <= 0.04045) then
    return v / 12.92
   else 
    return ((v + 0.055) / 1.055)^2.4
  end if
end function

function decodeDC (value as integer) 
  intR = value >> 16
   intG = (value >> 8) AND 255
   intB = value AND 255
 
  return [sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB)]

end function

function decodeAC (value as float, maximumValue as float)
  
  quantR = Fix(value / (19 * 19))
  quantG = Fix(value / 19) mod 19
  quantB = value mod 19

  rgb = [
    signPow((quantR - 9) / 9, 2.0) * maximumValue,
    signPow((quantG - 9) / 9, 2.0) * maximumValue,
    signPow((quantB - 9) / 9, 2.0) * maximumValue
  ]

  return rgb
end function


function signPow (val as float, exp as float) 

  result = Abs(val)
  for i = 1 to exp step 1 
    result = result * val
  end for

  return Sgn(val) * val^exp

end function

function linearTosRGB (value as float)
  
  v = value

  if value < 0
    v = 0
  else if value > 1
    v = 1
  end if

  if v <= 0.0031308 then 
    return Cint(v * 12.92 * 255 + 0.5)
  else 
    return Cint((1.055 * (v^(1 / 2.4)) - 0.055) * 255 + 0.5)
  end if
end function



function decodeBlurhash (blurhash as string, width as integer, height as integer, punch = 1 as float)

  if isBlurhashValid(blurhash) = false then return invalid

  sizeFlag = decode83(Mid(blurhash, 1, 1))
   numY = Fix(sizeFlag / 9) + 1
   numX = (sizeFlag mod 9) + 1

  quantisedMaximumValue = decode83(Mid(blurhash, 2, 1))
  maximumValue = (quantisedMaximumValue + 1) / 166

  colors = []

  colorsLength = numX * numY

  for i = 0 to colorsLength - 1
    if i = 0 then
      
      value = decode83(Mid(blurhash, 3, 4))

      colors[i] = decodeDC(value)


    else
      value = decode83(Mid(blurhash, 5 + i * 2, 2))
      colors[i] = decodeAC(value, maximumValue * punch)
    end if
  end for


  bytesPerRow = width * 4
  pixels = [] 

  for i = 0 to (bytesPerRow * height) - 1
    pixels[i] = 0
  end for

  for y = 0 to height step 1 

'  for (let y = 0; y < height; y++) {
 
  '  for (let x = 0; x < width; x++) {
    for x = 0 to width - 1 step 1 

      r = 0
      g = 0
      b = 0

'      for (let j = 0; j < numY; j++) {
      for j = 0 to numY - 1 

  '      for (let i = 0; i < numX; i++) {
        for i = 0 to numX - 1
          
          basis = cos((3.14159265 * x * i) / width) * cos((3.14159265 * y * j) / height)
          
          color = colors[i + j * numX]
          r = r + color[0] * basis
          g = g + color[1] * basis
          b = b + color[2] * basis
        end for
      end for

      intR = linearTosRGB(r)
      intG = linearTosRGB(g)
      intB = linearTosRGB(b)

      pixels[4 * x + 0 + y * bytesPerRow] = intR
      pixels[4 * x + 1 + y * bytesPerRow] = intG
      pixels[4 * x + 2 + y * bytesPerRow] = intB
      pixels[4 * x + 3 + y * bytesPerRow] = 255 ' Alpha
    end for
  end for
  return pixels

end function