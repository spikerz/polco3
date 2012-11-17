module BillsHelper

  def pie_chart(tally)
    # also like Sand and Shade: 8E9E63|E6DBB0|F5EED7|C4BCA0|176573 #
    # used satisfying results by ben.eelen
    # we can also use: DB9E36
    unless tally.values.all? { |t| t==0 }
      chart_root = "http://chart.apis.google.com/chart"
      vals = {
          # what is the size of the chart?
          chs: '70x63',
          # what chart type?
          cht: 'p',
          # what are the chart colors (in the same order as the data)
          # chco=<slice_1>|<slice_2>|<slice_n>,<series_color_1>,...,<series_color_n>
          chco: '1B8598|EE6514|DEE8E8|A5B0B0',
          # Text Format with Custom Scaling
          chds: 'a',
          # the actual data
          chd: "t:#{tally[:ayes]},#{tally[:nays]},#{tally[:abstains]},#{tally[:presents]}",
          # Pie Chart Rotation | chp=<radians>
          chp: '0.0',
          #chma=<left_margin>,<right_margin>,<top_margin>,<bottom_margin>|<opt_legend_width>,<opt_legend_height>
          chma: '|2'
      }
      query = vals.map { |k, v| "#{k}=#{v}" }.join("&")
      alt_tag = tally.map { |k, v| "#{k}: #{v}" }.join(",")
      image_tag("#{chart_root}?#{query}", size: "70x63", alt: alt_tag, style: "box-shadow:none;").html_safe
      #%q{<img src="http://chart.apis.google.com/chart?chs=70x63&cht=p&chco=009900|E20000|76A4FB|990066&chds=-3.333,100&chd=t:32.787,50.82,100,42.623&chp=0.067&chma=|2" width="70" height="63" alt="" />}.html_safe
    else
      "no votes"
    end
  end
end
