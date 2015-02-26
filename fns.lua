function between(n,a,b)
	n = tonumber(n,10) or 0
	a = tonumber(a,10) or 0
	b = tonumber(b,10) or 0
	
	return (n >= a and n <= b)
end


function quit(input)
	return (input == "x" or input == "X")
end
