module Template
  # templates:
  #   #{foo}
  #   #{foo.bar}
  #   #{foo[baz]}
  #   #{foo[baz].bar}
  TemplateRE = /\#\{
    (?<foo>[^\.\[\]\}]+)      # foo
    (\[(?<baz>[^\[\]\}]+)\])? # baz
    (\.(?<bar>[\w\?]+))?      # bar
    \}/x
  def template(args = {})
    # add string key via symbol key, to simplify the caller
    extras = {}
    args.each do |k,v|
      if k.is_a?(Symbol) && !args.has_key?(k.to_s)
        extras[k.to_s] = v
      end
    end
    args.merge! extras

    # execute template
    self.gsub(TemplateRE) do |match|
      foo = $~[:foo]
      baz = $~[:baz]
      if baz && baz.start_with?(":")
        baz = baz.delete(":").to_sym
      end
      bar = $~[:bar]
      #puts "foo:#{foo} baz:#{baz} bar:#{bar}"
      if args[foo]
        val = args[foo]
        if baz
          val = val.is_a?(Array) ? val[baz.to_i] : val[baz]
        end
        if bar
          val = val.send(bar)
        end
        val.to_s
      else
        match
      end
    end
  end
end

# include the extension
String.send(:include, Template)

__END__

baz1 = Struct.new(:bar).new("baz1")
baz2 = Struct.new(:bar).new("bar2")
foo = {
  baz: baz1
}

s = '#{baz} #{baz.bar} #{foo[:baz]} #{foo[:baz].bar}'

puts s
puts "-->"
puts s.template("foo" => foo, "baz" => baz1 )
s = '#{foo[0]} #{foo[1].bar}'
foo = [baz1, baz2]
puts s.template("foo" => foo, "baz" => baz2 )

