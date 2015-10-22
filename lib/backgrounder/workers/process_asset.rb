module CarrierWave
  module Workers
    class ProcessAsset
      include Sidekiq::Worker

      def perform(gid, column)
        record = GlobalID.find(gid)
        if record && record.public_send(column).present?
          record.send(:"process_#{column}_upload=", true)
          if record.send(column).recreate_versions! && record.respond_to?(:"#{column}_processing")
            record.update_attribute(:"#{column}_processing", false)
          end
        end
      end
    end
  end
end
