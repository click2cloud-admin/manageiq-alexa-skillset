require 'alexa_generator'
require 'json'

model = AlexaGenerator::InteractionModel.build do |model|
  model.add_intent(:ManageIQ) do |intent|
    intent.add_slot(:Provider, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
      slot.add_bindings(*%w{Amazon Azure Google VMware})
    end

    intent.add_utterance_template('How many VMs are {Provider} running?')
  end
end

puts JSON.pretty_generate(model.intent_schema)

puts model.sample_utterances(:ManageIQ)
