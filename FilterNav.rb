#encoding: utf-8
require 'date'

MainRawPath = "D:/CbIP/CbIP/prj/VerifyNavigation/verifyNav/RawNavigate/"

$:.unshift(File.dirname(__FILE__)+"/../MapMatchingAlgotithms/bin_0.2/commonStructs/")
require 'geometry.rb'
require 'path.rb'

$:.unshift(File.dirname(__FILE__)+"/../MapMatchingAlgotithms/bin_0.2/dataAccumulator/")
require 'accum.rb'

$:.unshift(File.dirname(__FILE__)+"/../MapMatchingAlgotithms/bin_0.2/")
require 'roadGraphUsingExample.rb'



class Vehicle
	:day
	:route
	:garage
	def initialize(day, route, garage)
		@day = day
		@route = route
		@garage = garage
	end
end

class NavData
	attr_accessor :time
	#attr_accessor :lat
	#attr_accessor :lon
	attr_accessor :point
	attr_accessor :mark
	attr_accessor :azimut
	attr_accessor :speed
	def initialize
		@time 	=[]
		#@lat 	=[]
		#@lon 	=[]
		@point	=[]
		@mark 	=[]
		@azimut =[]
		@speed 	=[]
		
	end

	def copy_from(data, index)
		@time << data.time[index]
		@point << data.point[index]
		@mark << data.mark[index]
		@azimut << data.azimut[index]
		@speed << data.speed[index]
		
	end

	def printData
		size = @time.size
		p1 = @point[0]
		for i in 1..size-1
			p2 = @point[i]

				puts "#{p1.x};#{p1.y};#{p2.x};#{p2.y};#{@time[i]}"

			p1=p2
		end		
	end

	def deleteAt(index)
		@time.delete_at(index)
		@point.delete_at(index)
		@mark.delete_at(index)
		@azimut.delete_at(index)
		@speed.delete_at(index)

	end
end

class NavVehicle < Vehicle
	attr_accessor :ndata
	def initialize(d,r,g)
		super(d,r,g)
		@ndata = NavData.new
	end

	def createDateTime(str)
		year	= str.split(" ")[0].split("-")[0].to_i
		month	= str.split(" ")[0].split("-")[1].to_i
		day		= str.split(" ")[0].split("-")[2].to_i
		hour	= str.split(" ")[1].split(":")[0].to_i
		min		= str.split(" ")[1].split(":")[1].to_i
		sec		= str.split(" ")[1].split(":")[2].to_i
		
		return Time.new(year, month, day, hour, min, sec)
	end

	def LoadData
		f = IO.read("#{MainRawPath}#{@day}/#{@route}/#{@route}-[#{@garage}].txt")

		f = f.split("\n")
		strs = f.size

		for i in 1..strs-1
			time	= f[i].split("\t")[0]
			lat		= f[i].split("\t")[1]
			lon		= f[i].split("\t")[2]
			mark	= f[i].split("\t")[3]
			azimut	= f[i].split("\t")[4]
			speed	= f[i].split("\t")[5]

			time = createDateTime(time)

			pt = Point.new(lon, lat)


			@ndata.time << time
			#@ndata.lat 	<< lat
			#@ndata.lon 	<< lon
			@ndata.point << pt
			@ndata.mark 	<< mark
			@ndata.azimut << azimut
			@ndata.speed 	<< speed
		end
	end

	def printData
		size = @ndata.time.size
		for i in 0..size-1
			puts "#{@ndata.time[i]}\t#{@ndata.point[i].getCoordinates}\t#{@ndata.mark[i]}\t#{@ndata.azimut[i]}\t#{@ndata.speed[i]}\n"
		end
	end

	def filterDoublingPoints
		geom = Geometry.new

		size = @ndata.time.size
		#time1 = @ndata.time[0]
		pt1 = @ndata.point[0]
		indexToDelete = []

		for i in 1..size-1

			#time2 = @ndata.time[i]
			pt2 = @ndata.point[i]
			#dTime = time2-time1
			#len = geom.spatialLength2D(pt1, pt2)

			if (pt1.isEqual(pt2))
				indexToDelete << i-1
			end

			#vel = (len/dTime.to_f)*(3600)





			#time1 = time2
			pt1 = pt2
			#puts "dTime = #{dTime}\tvel = #{vel}\tlen = #{len}\n"
		end
		
		
		indexToDelete.reverse.each{|index|
			@ndata.deleteAt(index)
		}
		
	end

	def filterTimeInterval

		intervals = []

		
		size = @ndata.time.size
		time1 = @ndata.time[0]
		pt1 = @ndata.point[0]
		indexToDelete = []
		nd = NavData.new
		nd.copy_from(@ndata,0)

		for i in 1..size-1
			
			time2 = @ndata.time[i]
			dTime = time2-time1

			

			if (dTime>120)
				intervals << nd
				#puts "#{dTime} (#{i})"
				nd = NavData.new
			end

			nd.copy_from(@ndata,i)
			#elsif (dTime==0)
			#	puts "time is ZERO #{i}"
			#end

			time1 = time2
			
		end
		intervals << nd

		return intervals
	end


	def filterData
		filterDoublingPoints
		#printData
		res = filterTimeInterval

#		res.each{|arrNavData|
#			puts "*************"
#			#arrNavData.printData
#			puts arrNavData.inspect
#		}

		return res


	end
end

#def puts (str)
#	print "#{caller[0].split(" ")[-1][1..-2]}: #{str}\n"
#end


@@DEBUG = false
@@TEST_DATA = true

class StartCalculating
	:accumulator
	def initialize
		@accumulator = Accumulator.new
	end

	def start
		if (@@TEST_DATA)
			nv = NavVehicle.new("24.11.2014", "test", "6271")
		else
			nv = NavVehicle.new("24.11.2014", "013", "6271")
		end
		nv.LoadData
		res = nv.filterData
		
		
		for i in 0..0#res.size-1
		#for i in 0..res.size-1
			#puts "*************"
			#res[i].printData
			size = res[i].time.size
			p1 = res[i].point[0]
			time1 = res[i].time[0]
		
		
			for j in 1..size-1
		#	for j in 51..51
			#for j in 11..11 #bridge test
		 
		
				p2 = res[i].point[j]
				time2 = res[i].time[j]

p "****path #{i}:#{j}**** #{p1.inspect};#{p2.inspect}"
		
				roadPath = getPath(p1,p2)
				
				roadPath.setPoints(p1, p2)
				roadPath.setTimes(time1, time2)
				dt = time2 - time1

				#puts dt
				#puts roadPath.getPathLen
				#geom = Geometry.new
				#len = geom.spatialLength2D(p1, p2)
				#puts "len Straight = #{len}"

				
				vel = (roadPath.getPathLen/dt.to_f)*(3600)
				roadPath.setVelocity(vel)
				@accumulator.add(roadPath)
				#exit

				p1=p2
				time1 = time2
			end
		
		end
	end

end



startCalc = StartCalculating.new
startCalc.start



#37.4730339050293;55.775238037109375;37.47613525390625;55.77463150024414

#geom = Geometry.new
#p1 = Point.new(37.4730339050293, 55.775238037109375)
#p2 = Point.new(37.47613525390625, 55.77463150024414)
#len = geom.spatialLength2D(p1, p2)
#p len

#что то очень медленно работает:
#<Point:0x2299ff8 @x=37.729632, @y=55.827098>
#<Point:0x22d29b0 @x=37.609908, @y=55.806995>

