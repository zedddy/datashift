# Copyright:: (c) Autotelik Media Ltd 2015
# Author ::   Tom Statter
# License::   MIT
#
# Details::   Specs around Transforming inbound data
#
require File.dirname(__FILE__) + '/../spec_helper'

module  DataShift

  describe 'Transformer Remove' do
    include_context 'ClearThenManageProject'

    context 'Column removals' do
      it 'should process options to remove unwanted columns' do
        headers = [:a, :b, :c, :d, :e, :f]

        DataShift::Exporters::Configuration.configure do |config|
          config.remove = [:b, :f]
        end

        DataShift::Transformer::Remove.unwanted_columns(headers )

        expect(headers).to_not include [:b, :f]
      end

      it 'should process options to remove unwant5ed columns' do
        headers = [:a, :id, :c, :d, :e, :created_on, :f, :updated_on]

        DataShift::Exporters::Configuration.configure do |config|
          config.remove_rails = true
        end

        DataShift::Transformer::Remove.unwanted_columns(headers)

        expect(headers).to_not include [:id, :created_on, :updated_on]
      end

    end

  end

end
