require_relative "./inputs"

puts "day01"
->(n){->(i){p i.combination(n).find{_1.sum==2020}.reduce(:*)}}.tap{|e|I1.split.map(&:to_i).tap(&e[2]).tap(&e[3])}

puts "\nday02"
puts I2.scan(/(\d+)-(\d+) (\w): (\w+)/).map{|a,b,c,d|[a.to_i,b.to_i,c,d]}.reduce([0]*2){|(x,y),(a,b,c,d)|[x+((a..b).cover?(d.count c)?1:0),y+((d[a-1]==c)^(d[b-1]==c)?1:0)]}

puts "\nday03"
I3.split.map{_1.split("")}.yield_self{|m|[[1,1],[3,1],[5,1],[7,1],[1,2]].map{|x,y|(0..(m.length-1)).count{|i|(i%y==0)&&(m[i][((i*x)/y)%m[i].length]=='#')}}}.tap{p(_1[1],_1.reduce(:*))}