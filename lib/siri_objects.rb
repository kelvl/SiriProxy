require 'rubygems'
require 'uuidtools'
require 'cfpropertylist'

def generate_siri_utterance(ref_id, text, speakableText=text, listenAfterSpeaking=false)
  object = SiriAddViews.new
  object.make_root(ref_id)
  object.views << SiriAssistantUtteranceView.new(text, speakableText, "Misc#ident", listenAfterSpeaking)
  return object.to_hash
end

def generate_request_completed(ref_id, callbacks=nil)
  object = SiriRequestCompleted.new()
  object.callbacks = callbacks if callbacks != nil
  object.make_root(ref_id)
  return object.to_hash
end

def generate_speech_recognized(ref_id, text)
  object = SiriSpeechRecognized.new(text)
  object.make_root(ref_id)
  return object.to_hash
end

def generate_show_help(ref_id)
	object = SiriShowHelp.new()
	object.make_root(ref_id)
	return object.to_hash
end

def generate_get_session_certificate_response(ref_id)
	object = SiriGetSessionCertificateResponse.new()
	object.make_root(ref_id)
	return object.to_hash
end

def generate_web_search_request_completed(ref_id, query)
	object = SiriWebSearchRequestCompleted.new(query)
	object.make_root(ref_id)
	return object.to_hash
end
	
class SiriObject
  attr_accessor :klass, :group, :properties
  
  def initialize(klass, group)
    @klass = klass
    @group = group
    @properties = {}
  end
  
  #watch out for circular references!
  def to_hash
    hash = {
      "class" => self.klass,
      "group" => self.group,
      "properties" => {}
    }
    
    (hash["refId"] = ref_id) rescue nil
    (hash["aceId"] = ace_id) rescue nil
    
    properties.each_key { |key|
      if properties[key].class == Array
        hash["properties"][key] = []
        self.properties[key].each { |val| hash["properties"][key] << (val.to_hash rescue val) }
      else
        hash["properties"][key] = (properties[key].to_hash rescue properties[key])
      end
    }

    hash
  end
  
  def make_root(ref_id=nil, ace_id=nil)
    self.extend(SiriRootObject)
  
    self.ref_id = (ref_id || random_ref_id) 
    self.ace_id = (ace_id || random_ace_id)
  end
end

def add_property_to_class(klass, prop)
  klass.send(:define_method, (prop.to_s + "=").to_sym) { |value|
    self.properties[prop.to_s] = value
  }
  
  klass.send(:define_method, prop.to_s.to_sym) {
    self.properties[prop.to_s]
  }
end

module SiriRootObject
  attr_accessor :ref_id, :ace_id
  
  def random_ref_id
    UUIDTools::UUID.random_create.to_s.upcase
  end
  
  def random_ace_id
    UUIDTools::UUID.random_create.to_s
  end
end

class SiriGetSessionCertificateResponse < SiriObject
	@@certificate_blob = "\x01\x02\x00\x00\x04\x160\x82\x04\x120\x82\x02\xFA\xA0\x03\x02\x01\x02\x02\x01\x1C0\r\x06\t*\x86H\x86\xF7\r\x01\x01\x05\x05\x000b1\v0\t\x06\x03U\x04\x06\x13\x02US1\x130\x11\x06\x03U\x04\n\x13\nApple Inc.1&0$\x06\x03U\x04\v\x13\x1DApple Certification Authority1\x160\x14\x06\x03U\x04\x03\x13\rApple Root CA0\x1E\x17\r110126190134Z\x17\r190126190134Z0\x81\x851\v0\t\x06\x03U\x04\x06\x13\x02US1\x130\x11\x06\x03U\x04\n\f\nApple Inc.1&0$\x06\x03U\x04\v\f\x1DApple Certification Authority1907\x06\x03U\x04\x03\f0Apple System Integration Certification Authority0\x82\x01\"0\r\x06\t*\x86H\x86\xF7\r\x01\x01\x01\x05\x00\x03\x82\x01\x0F\x000\x82\x01\n\x02\x82\x01\x01\x00\xDA\xE0\x0F\x98\x97\xCBX)\x86*\v\xB8\x9E\x19Z1\xC3-\x0Ej,R\x01\xEE\x1D\x03\xFB\x82Ai\xCDP&6z\xB7\fo\x0E9\x03\xB8\xD4\x18V\xA3\b\xB2<\xC3\xFB6A\xE4\xD7\xC8g`2\vN2}\x87\xF7\xFD\xCDS\xB0\x1A\xBA\xFC\x1Fl\xC9E\a\xAD\x828\xF3\xA8|\xC4N\xC2\xB1V\xD9>\xB2mm\x04A\x1A\xC1\x9AG\xC0\xAC\x15|-x\x91\xAB\a\xA2e\xB1z\x83\xDD\x98Kw@\xD8\xEEP\xEB\xC7kX\b\x06\x97WU}'\xF8\n\xE6\xB5\x15\xE7\xA7\x93\xF9\xF1\x80\xE6By?\x16\xD32\x9D\x11vA)\n1\t\xEF\x0F[\xF8\xF3\xA7\xA9\xF7R\r\xBB\xF8-t\xAC\xA6I\x1F\x1F\xCE{\x05\xA7\x85=\xBE\xCF\xA2\xA7\xAA#\x85f\xFE\xC5\x16\x12~[\xE21w\x91\x02\t\xDF~~\xE4\x8A\xE0\xECA\xAC\x17,\x04\xE0\xBCy\xA4\x89xD\x06\x8B;K\xA0\xBC\x84\xE2\xB0\x82\xB52\xBE\x04\x1C\x03\xED\x82>u7\x14\xCFu\x9F\x821m\xCF\t\x14\x86\xD1'\x02\x03\x01\x00\x01\xA3\x81\xAE0\x81\xAB0\x0E\x06\x03U\x1D\x0F\x01\x01\xFF\x04\x04\x03\x02\x01\x860\x0F\x06\x03U\x1D\x13\x01\x01\xFF\x04\x050\x03\x01\x01\xFF0\x1D\x06\x03U\x1D\x0E\x04\x16\x04\x14\xF00sc\xF2\xEF\x1D\xAC\xCC\xE6\t2\xC1\xFAyz\xB1iPh0\x1F\x06\x03U\x1D#\x04\x180\x16\x80\x14+\xD0iG\x94v\t\xFE\xF4k\x8D.@\xA6\xF7GM\x7F\b^06\x06\x03U\x1D\x1F\x04/0-0+\xA0)\xA0'\x86%http://www.apple.com/appleca/root.crl0\x10\x06\n*\x86H\x86\xF7cd\x06\x02\x04\x04\x02\x05\x000\r\x06\t*\x86H\x86\xF7\r\x01\x01\x05\x05\x00\x03\x82\x01\x01\x00={\x8F\xAD\x1F\f\"\x8A\x9BK\xA3\xCF\xF8+\xB0\x1Fh\xE1\f\xF7\x9C$\x83\x16\x03-\xD3\xB2\xA8\xD0C\xE8\xAF<\x97&\xC8\xAD\xD5,\xC4LUS\x01I\xD0\xE2\xB4\xFB\xE6\xDBr\xD1\x98\xBB\xFC\x9B\xC8N\xB7\x8F\xCCe\x86\x7FD\xB9\xDA'*N\xDF\xCB\xDF\xD3}\xDFAq\xF8\xB3\xC0\x1D\xA2\n3\xB9\xEC+\xC5sr\xFB\xE1\xCA]\x8E/4\xF4k\xC4O\x0F\xC8\x8A\xAC\x0F\xFBo%n\xB7\xAE\x8E\xC7\xE4\x02\xB8 N]VLI\x97\xB1$t~\xC9\x93\x934\x8C\x99\xD1\xA7\xC0\x1C\xD3\xD4\xC2\xAEi\xEB\x9F\x9FW\xE2h\xC7\xCA\xD5\xC5\"\x82dAX\xFEx\xD1\xCA\xC1\xF96jkD\xF7\xB3\x86rzd@\x171\x9D\xBC\xACu\xF0\xFA3Q\xE5\xBD\x01jX?\xF0\x00\xAE\x99\\\n\xC2\xC9\xE9^\x1C\x87\x02\xEC\xA0\bUA*\x9B\x8Cd\x85\x8EP\x03\xCD\xE0\x11\xAF\xCEr\x19\xEBR\xF3\xAF\x92\xAD\x93.\x94\x9D\xD6\xAF\xFF\xC0&\xF1\xDE\x94\x92\x1C\xD9\xBC=6\xCCU\xFA8\xDB\x00\x00\x0510\x82\x05-0\x82\x04\x15\xA0\x03\x02\x01\x02\x02\bK,\x91H\x1D\x9B}\xA00\r\x06\t*\x86H\x86\xF7\r\x01\x01\x05\x05\x000\x81\x851\v0\t\x06\x03U\x04\x06\x13\x02US1\x130\x11\x06\x03U\x04\n\f\nApple Inc.1&0$\x06\x03U\x04\v\f\x1DApple Certification Authority1907\x06\x03U\x04\x03\f0Apple System Integration Certification Authority0\x1E\x17\r110325011332Z\x17\r140324011332Z0i1\x1D0\e\x06\x03U\x04\x03\f\x14DRM Technologies A011&0$\x06\x03U\x04\v\f\x1DApple Certification Authority1\x130\x11\x06\x03U\x04\n\f\nApple Inc.1\v0\t\x06\x03U\x04\x06\x13\x02US0\x82\x01\"0\r\x06\t*\x86H\x86\xF7\r\x01\x01\x01\x05\x00\x03\x82\x01\x0F\x000\x82\x01\n\x02\x82\x01\x01\x00\xB4\x06m~es\x97\xE1\xBFI\xB1\xFA\x9A\".\xA7\xD3q\x81 kIA\x15\xC2\xDB`z\xC6\xA2\xB7Mz/\x8E\xC1c\a\x1C\x04\xCC\x93\xD8\xE0\r\xC8\xB8\xF2[\xCEm\xFAB\xCB\x10@\xC2$\n\xA7\xE4\x1D&\x82\x8A>0\x86]\xED\x178\xEE\x87\xAB\xBD\xE8HJIw\x85.\xB7\x91\x84\x9B)}A\x05\xA0y\xF5\xAD\x8C\xC1\v\xD8\x9Di\xE7\x9C\xB2\xA9F\xD0K\xFE\t\x18P$\x8AYG+\"UG\xEDQ\"\x9DB\xE9\x9D\xEE\x81\xC3G\xCD\xE4o\n*?O+\xD2\x04\xD0\xB8\x8C\xE8d\x98\xDF\xCE`S\x9B\x88\x1A\xCF\xD4\xC2\rte\xBF\xF3\x85\x87_K\x87\x10\xA2\x87\x8Am>@U\x0E\xF9\x9F\x99\xCC2\x93\x83Q\x88\xC9\xB9\xF8^\xC9\x19_\x17\xE7k\x9B|:\xDD\xFFh\xDF\xD4\xD14Ut\xEC\xF7K\xE8\x1C\x90u\x85\xF2\xFCC\xFF\xA5D#R?\xFB\xF5!\xE3\x83\x16?\xBE\nt\xF9<t\x99j\xFE?\xD2Z\xA1P\xE3.\x8BH\r\"&;\xD5\x9EI\x02\x03\x01\x00\x01\xA3\x82\x01\xBA0\x82\x01\xB60\x1D\x06\x03U\x1D\x0E\x04\x16\x04\x14\xD2$#\xFB\xEB\xE8\x8E\x8Fq\x9C\x84\xEEbs=\xE9^$\t/0\f\x06\x03U\x1D\x13\x01\x01\xFF\x04\x020\x000\x1F\x06\x03U\x1D#\x04\x180\x16\x80\x14\xF00sc\xF2\xEF\x1D\xAC\xCC\xE6\t2\xC1\xFAyz\xB1iPh0\x82\x01\x0E\x06\x03U\x1D \x04\x82\x01\x050\x82\x01\x010\x81\xFE\x06\t*\x86H\x86\xF7cd\x05\x010\x81\xF00(\x06\b+\x06\x01\x05\x05\a\x02\x01\x16\x1Chttp://www.apple.com/appleca0\x81\xC3\x06\b+\x06\x01\x05\x05\a\x02\x020\x81\xB6\f\x81\xB3Reliance on this certificate by any party assumes acceptance of the then applicable standard terms and conditions of use, certificate policy and certification practice statements.0/\x06\x03U\x1D\x1F\x04(0&0$\xA0\"\xA0 \x86\x1Ehttp://crl.apple.com/asica.crl0\x0E\x06\x03U\x1D\x0F\x01\x01\xFF\x04\x04\x03\x02\x05\xA00\x13\x06\n*\x86H\x86\xF7cd\x06\f\x01\x01\x01\xFF\x04\x02\x05\x000\r\x06\t*\x86H\x86\xF7\r\x01\x01\x05\x05\x00\x03\x82\x01\x01\x00}y\xA7cnA;\xBE\xC1\xCE\xB1\x8C\xFAm0 \xB8\xBAI0\x92=\x1DU\xCE\xB9\xC2-Kb\xC5\xCA@\xF6\xB7\xBC\xB1\xF6\xD2\xA6\xFA\xAD\x01kO\x1C\xCC\xAE\xCEF \xFF\xC2\xB3\xC0,wO\xD0\x13DL\x87\xC7a-\x0F\xC7\xCCC.7:7\xFD\xAE\x98\x9A\x12\xB6I\xB0\xAAw\xD3S\x81\x96\x80\xCD\x84\xDBs\xAAG\xA8 V6\xC2\xD9\xA5\xE9\f<\"\x1Dy\xEF\xE7\xB0O\t}^\xFB\xB2\"\xA3\xB6\xF7#%\t\x83y\xA84V\x84\xE6E\xAD\"\xA1\x1CU\x9C\xA2/\x1F\xB6!\xB9\xFF\xD8\x0F\xC9s\tv\xF0\x03\x17\x19\x8F\xE9\xA3\xFC\xE6B\xCB_d\x86\x96\x8Ch?\xC2\xA0XB\xD4\x9Fvm\x95\xBF\xC0\xF7\xDB\x14t\xFCZ\xA8\x82\xC7\xA6\xFCV\x8A7\xB7\xC8r\x9C\xBC\x9BD\xD1F\xE2\x8D$\xD9\x7F'y\xF1t\xB9\xC5\xB2\xB0\xC2\xE1&\x06\xE4\xFF\xAF\xA5\v\xD9\xA3\x1E\x95\xDBD\x91\xCC\xE9K\x022\x03\xE6R\xF6\xA7*Z#4\xD0\x1D\x17\xF2\xEB\xEA\xC2y\n\xE9"
	@@certificate_blob.blob = true

	def initialize()
		super("GetSessionCertificateResponse", "com.apple.ace.system")
		self.properties = {"certificate"=> @@certificate_blob}
	end
end

class SiriShowHelp < SiriObject
	def initialize()
		super("ShowHelp", "com.apple.ace.assistant")
		self.properties = {
			"speakableText"=>"You can say things like:",
		    "text"=>"You can say things like:"
		    }
	end
end

class SiriWebSearchRequestCompleted < SiriObject
	def initialize(query)
		super("RequestCompleted", "com.apple.ace.system")
		self.properties = {"callbacks"=>
		    [{"class"=>"ResultCallback",
		      "properties"=>
		       {"commands"=>
		         [{"class"=>"AddViews",
		           "properties"=>
		            {"temporary"=>false,
		             "dialogPhase"=>"Completion",
		             "views"=>
		              [{"class"=>"AssistantUtteranceView",
		                "properties"=>
		                 {"dialogIdentifier"=>"WebSearch#initiateWebSearch",
		                  "speakableText"=>"Searching for #{query}",
		                  "text"=>"Searching for '#{query}'...",
		                  "listenAfterSpeaking"=>false},
		                "group"=>"com.apple.ace.assistant"}],
		             "scrollToTop"=>false,
		             "callbacks"=>
		              [{"class"=>"ResultCallback",
		                "properties"=>
		                 {"commands"=>
		                   [{"class"=>"Search",
		                     "properties"=>
		                      {"query"=>"#{query}",
		                       "provider"=>"Default",
		                       "callbacks"=>
		                        [{"class"=>"ResultCallback",
		                          "properties"=>
		                           {"commands"=>
		                             [{"class"=>"AddViews",
		                               "properties"=>
		                                {"temporary"=>false,
		                                 "dialogPhase"=>"Completion",
		                                 "scrollToTop"=>false,
		                                 "views"=>
		                                  [{"class"=>"AssistantUtteranceView",
		                                    "properties"=>
		                                     {"dialogIdentifier"=>
		                                       "WebSearch#fatalResponse",
		                                      "speakableText"=>
		                                       "Sorry, I can't search the web right now.",
		                                      "text"=>
		                                       "Sorry, I can't search the web right now.",
		                                      "listenAfterSpeaking"=>false},
		                                    "group"=>"com.apple.ace.assistant"}]},
		                               "aceId"=>UUIDTools::UUID.random_create.to_s,
		                               "group"=>"com.apple.ace.assistant"}],
		                            "code"=>-1},
		                          "group"=>"com.apple.ace.system"}]},
		                     "group"=>"com.apple.ace.websearch"}],
		                  "code"=>0},
		                "group"=>"com.apple.ace.system"}]},
		           "aceId"=>UUIDTools::UUID.random_create.to_s,
		           "group"=>"com.apple.ace.assistant"}],
		        "code"=>0},
		      "group"=>"com.apple.ace.system"}]}
	end
end

class SiriSpeechRecognized < SiriObject
	def initialize(text)
		super("SpeechRecognized", "com.apple.ace.speech")
		self.properties = { # fill a template
			"sessionId"=>UUIDTools::UUID.random_create.to_s,
   			"recognition"=>
    			{
					"class"=>"Recognition",
     				"properties"=>
      					{
							"phrases"=>nil # all phrases and tokens go in here
						},
     				"group"=>"com.apple.ace.speech"
				}
		}
		
		# tokenize the text and inject each token into the "phrases" array as a "phrase"		
		phrases = []
		confidence = 0.9
		tokens = text.split(/\b+/)
		tokens.each_with_index do |value, index|
			if value != " " 
				phrases << {
								"class"=>"Phrase",
									"properties"=>
										{
										"interpretations"=>
												[
												{
													"class"=>"Interpretation",
														"properties"=>
														{
															"tokens"=>
																	[
																	{
																		"class"=>"Token",
																		"properties"=>
																			{
																				"removeSpaceBefore"=> (index - 1) < 0 || tokens[index - 1] != " ",
																				"confidenceScore"=>(confidence * 1000).to_int,
																				"removeSpaceAfter"=> tokens[index + 1] == nil || tokens[index + 1] != " ",
																				"endTime"=>0,
																				"text"=>value,
																				"startTime"=>0
																		},
																		"group"=>"com.apple.ace.speech"
																	}
																]
														},
														"group"=>"com.apple.ace.speech"
												}
											],
										"lowConfidence"=>false
									},
									"group"=>"com.apple.ace.speech"
							}
			end
		end
		self.properties["recognition"]["properties"]["phrases"] = phrases
	end
end

class SiriAddViews < SiriObject
  def initialize(scrollToTop=false, temporary=false, dialogPhase="Completion", views=[])
    super("AddViews", "com.apple.ace.assistant")
    self.scrollToTop = scrollToTop
    self.views = views
    self.temporary = temporary
    self.dialogPhase = dialogPhase
  end
end
add_property_to_class(SiriAddViews, :scrollToTop)
add_property_to_class(SiriAddViews, :views)
add_property_to_class(SiriAddViews, :temporary)
add_property_to_class(SiriAddViews, :dialogPhase)

#####
# VIEWS
#####

class SiriAssistantUtteranceView < SiriObject
  def initialize(text="", speakableText=text, dialogIdentifier="Misc#ident", listenAfterSpeaking=false)
    super("AssistantUtteranceView", "com.apple.ace.assistant")
    self.text = text
    self.speakableText = speakableText
    self.dialogIdentifier = dialogIdentifier
    self.listenAfterSpeaking = listenAfterSpeaking
  end
end
add_property_to_class(SiriAssistantUtteranceView, :text)
add_property_to_class(SiriAssistantUtteranceView, :speakableText)
add_property_to_class(SiriAssistantUtteranceView, :dialogIdentifier)
add_property_to_class(SiriAssistantUtteranceView, :listenAfterSpeaking)

class SiriMapItemSnippet < SiriObject
  def initialize(userCurrentLocation=true, items=[])
    super("MapItemSnippet", "com.apple.ace.localsearch")
    self.userCurrentLocation = userCurrentLocation
    self.items = items
  end
end
add_property_to_class(SiriMapItemSnippet, :userCurrentLocation)
add_property_to_class(SiriMapItemSnippet, :items)

class SiriButton < SiriObject
  def initialize(text="Button Text", commands=[])
    super("Button", "com.apple.ace.assistant")
    self.text = text
    self.commands = commands
  end
end
add_property_to_class(SiriButton, :text)
add_property_to_class(SiriButton, :commands)

class SiriAnswerSnippet < SiriObject
  def initialize(answers=[], confirmationOptions=nil)
    super("Snippet", "com.apple.ace.answer")
    self.answers = answers

    if confirmationOptions
      # need to figure out good way to do API for this
      self.confirmationOptions = confirmationOptions
    end

  end
end
add_property_to_class(SiriAnswerSnippet, :answers)
add_property_to_class(SiriAnswerSnippet, :confirmationOptions)

#####
# Items
#####

class SiriMapItem < SiriObject
  def initialize(label="Apple Headquarters", location=SiriLocation.new, detailType="BUSINESS_ITEM")
    super("MapItem", "com.apple.ace.localsearch")
    self.label = label
    self.detailType = detailType
    self.location = location
  end
end
add_property_to_class(SiriMapItem, :label)
add_property_to_class(SiriMapItem, :detailType)
add_property_to_class(SiriMapItem, :location)

#####
# Commands
#####

class SiriSendCommands < SiriObject
  def initialize(commands=[])
    super("SendCommands", "com.apple.ace.system")
    self.commands=commands
  end
end
add_property_to_class(SiriSendCommands, :commands)

class SiriConfirmationOptions < SiriObject
  def initialize(submitCommands=[], cancelCommands=[], denyCommands=[], confirmCommands=[], denyText="Cancel", cancelLabel="Cancel", submitLabel="Send", confirmText="Send", cancelTrigger="Deny")
    super("ConfirmationOptions", "com.apple.ace.assistant")

    self.submitCommands = submitCommands
    self.cancelCommands = cancelCommands
    self.denyCommands = denyCommands
    self.confirmCommands = confirmCommands

    self.denyText = denyText 
    self.cancelLabel = cancelLabel 
    self.submitLabel = submitLabel 
    self.confirmText = confirmText 
    self.cancelTrigger = cancelTrigger 
  end
end
add_property_to_class(SiriConfirmationOptions, :submitCommands)
add_property_to_class(SiriConfirmationOptions, :cancelCommands)
add_property_to_class(SiriConfirmationOptions, :denyCommands)
add_property_to_class(SiriConfirmationOptions, :confirmCommands)
add_property_to_class(SiriConfirmationOptions, :denyText)
add_property_to_class(SiriConfirmationOptions, :cancelLabel)
add_property_to_class(SiriConfirmationOptions, :submitLabel)
add_property_to_class(SiriConfirmationOptions, :confirmText)
add_property_to_class(SiriConfirmationOptions, :cancelTrigger)

class SiriConfirmSnippetCommand < SiriObject
  def initialize(request_id = "")
    super("ConfirmSnippet", "com.apple.ace.assistant")
    self.request_id = request_id
  end
end
add_property_to_class(SiriConfirmSnippetCommand, :request_id)

class SiriCancelSnippetCommand < SiriObject
  def initialize(request_id = "")
    super("ConfirmSnippet", "com.apple.ace.assistant")
    self.request_id = request_id
  end
end
add_property_to_class(SiriCancelSnippetCommand, :request_id)

#####
# Objects
#####

class SiriLocation < SiriObject
  def initialize(label="Apple", street="1 Infinite Loop", city="Cupertino", stateCode="CA", countryCode="US", postalCode="95014", latitude=37.3317031860352, longitude=-122.030089795589)
    super("Location", "com.apple.ace.system")
    self.label = label
    self.street = street
    self.city = city
    self.stateCode = stateCode
    self.countryCode = countryCode
    self.postalCode = postalCode
    self.latitude = latitude
    self.longitude = longitude
  end
end
add_property_to_class(SiriLocation, :label)
add_property_to_class(SiriLocation, :street)
add_property_to_class(SiriLocation, :city)
add_property_to_class(SiriLocation, :stateCode)
add_property_to_class(SiriLocation, :countryCode)
add_property_to_class(SiriLocation, :postalCode)
add_property_to_class(SiriLocation, :latitude)
add_property_to_class(SiriLocation, :longitude)

class SiriAnswer < SiriObject
  def initialize(title="", lines=[])
    super("Object", "com.apple.ace.answer")
    self.title = title
    self.lines = lines
  end
end
add_property_to_class(SiriAnswer, :title)
add_property_to_class(SiriAnswer, :lines)

class SiriAnswerLine < SiriObject
  def initialize(text="", image="")
    super("ObjectLine", "com.apple.ace.answer")
    self.text = text
    self.image = image
  end
end
add_property_to_class(SiriAnswerLine, :text)
add_property_to_class(SiriAnswerLine, :image)

#####
# Guzzoni Commands (commands that typically come from the server side)
#####

class SiriGetRequestOrigin < SiriObject
  def initialize(desiredAccuracy="HundredMeters", searchTimeout=8.0, maxAge=1800)
    super("GetRequestOrigin", "com.apple.ace.system")
    self.desiredAccuracy = desiredAccuracy
    self.searchTimeout = searchTimeout
    self.maxAge = maxAge
  end
end
add_property_to_class(SiriGetRequestOrigin, :desiredAccuracy)
add_property_to_class(SiriGetRequestOrigin, :searchTimeout)
add_property_to_class(SiriGetRequestOrigin, :maxAge)

class SiriRequestCompleted < SiriObject
  def initialize(callbacks=[])
    super("RequestCompleted", "com.apple.ace.system")
    self.callbacks = callbacks
  end
end
add_property_to_class(SiriRequestCompleted, :callbacks)

#####
# iPhone Responses (misc meta data back to the server)
#####

class SiriStartRequest < SiriObject
  def initialize(utterance="Testing", handsFree=false, proxyOnly=false)
    super("StartRequest", "com.apple.ace.system")
    self.utterance = utterance
    self.handsFree = handsFree
    if proxyOnly # dont send local when false since its non standard
      self.proxyOnly = proxyOnly
    end
  end
end
add_property_to_class(SiriStartRequest, :utterance)
add_property_to_class(SiriStartRequest, :handsFree)
add_property_to_class(SiriStartRequest, :proxyOnly)


class SiriSetRequestOrigin < SiriObject
  def initialize(longitude=-122.030089795589, latitude=37.3317031860352, desiredAccuracy="HundredMeters", altitude=0.0, speed=1.0, direction=1.0, age=0, horizontalAccuracy=50.0, verticalAccuracy=10.0)
    super("SetRequestOrigin", "com.apple.ace.system")
    self.horizontalAccuracy = horizontalAccuracy
    self.latitude = latitude
    self.desiredAccuracy = desiredAccuracy
    self.altitude = altitude
    self.speed = speed
    self.longitude = longitude
    self.verticalAccuracy = verticalAccuracy
    self.direction = direction
    self.age = age
  end
end
add_property_to_class(SiriSetRequestOrigin, :horizontalAccuracy)
add_property_to_class(SiriSetRequestOrigin, :latitude)
add_property_to_class(SiriSetRequestOrigin, :desiredAccuracy)
add_property_to_class(SiriSetRequestOrigin, :altitude)
add_property_to_class(SiriSetRequestOrigin, :speed)
add_property_to_class(SiriSetRequestOrigin, :longitude)
add_property_to_class(SiriSetRequestOrigin, :verticalAccuracy)
add_property_to_class(SiriSetRequestOrigin, :direction)
add_property_to_class(SiriSetRequestOrigin, :age)



