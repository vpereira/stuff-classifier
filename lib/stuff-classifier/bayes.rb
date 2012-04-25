# encoding: utf-8

class StuffClassifier::Bayes < StuffClassifier::Base
  # http://en.wikipedia.org/wiki/Naive_Bayes_classifier

  # opts :
  # language
  # stemming : true | false
  # weight
  # assumed_prob
  # storage
  # purge_state ?
  def initialize(name, opts={})
    super(name, opts)
    #max_prob for classify
    @thresholds = {}
  end

  def doc_prob(text, category)
    @tokenizer.each_word(text).map {|w|
      word_weighted_average(w, category)
    }.inject(1) {|p,c| p * c}
  end

  def text_prob(text, category)
    cat_prob = cat_count(category) / total_cat_count
    doc_prob = doc_prob(text, category)
    cat_prob * doc_prob
  end

  def cat_scores(text)
    probs = {}
    categories.each do |cat|
      probs[cat] = text_prob(text, cat)
    end
    probs.map{|k,v| [k,v]}.sort{|a,b| b[1] <=> a[1]}
  end

  def classify(text, default=nil)
    # Find the category with the highest probability
    max_prob = @min_prob
    best = nil

    scores = cat_scores(text)
    best, max_prob = scores.max_by { |k,v| v }
    #puts "#{best} -> #{max_prob}"
    #return default unless best
    
    # Return the default category in case the threshold condition was
    # not met. For example, if the threshold for :spam is 1.2
    #
    #    :spam => 0.73, :ham => 0.40  (OK)
    #    :spam => 0.80, :ham => 0.70  (Fail, :ham is too close)

    #return default unless best

    threshold = @thresholds[best] || 1.0

    #return default if max_prob < @max_prob or best.nil?

    #we should refactor it. Two times the same loop?
    #scores.each do |cat,prob|
    #  next if cat == best
    #  return default if prob * threshold > max_prob
    #end
    #scores.reject { |cat, prob| cat == best }.each do |cat,prob|
    #  return default if prob * threshold > max_prob
    #end
    #
    max_prob * threshold > @min_prob ? best : default
    #best 
  end

  def word_classification_detail(word)

    p "word_prob"
    result=self.categories.inject({}) do |h,cat| h[cat]=self.word_prob(word,cat);h end
    ap result

    p "word_weighted_average"
    result=categories.inject({}) do |h,cat| h[cat]=word_weighted_average(word,cat);h end  
    ap result

    p "doc_prob"
    result=categories.inject({}) do |h,cat| h[cat]=doc_prob(word,cat);h end  
    ap result

    p "text_prob"
    result=categories.inject({}) do |h,cat| h[cat]=text_prob(word,cat);h end  
    ap result
    
    
  end

end
