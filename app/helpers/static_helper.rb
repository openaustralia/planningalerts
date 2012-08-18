module StaticHelper
  # Randomise an array
  def shuffle(array)
    b = array.clone
    array.map{|a| b.slice!(rand b.length)}
  end
end
