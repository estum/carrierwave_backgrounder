module CarrierWave
  module Workers
    class StoreAsset
      include Sidekiq::Worker
      
      def perform(gid, column)
        record = GlobalID.find(gid)

        if record && record.send(:"#{column}_tmp")
          asset = record.send(column)
          asset_tmp = record.send(:"#{column}_tmp")
          cache_directory = File.expand_path(asset.cache_dir, asset.root)
          cache_path      = File.join(cache_directory, asset_tmp)
          tmp_directory   = File.join(cache_directory, asset_tmp.split("/")[0])

          record.send(:"process_#{column}_upload=", true)
          record.send(:"#{column}_tmp=", nil)
          record.send(:"#{column}_processing=", false) if record.respond_to?(:"#{column}_processing")

          File.open(cache_path) do |f|
            record.send(:"#{column}=", f)
          end

          if record.save!
            FileUtils.rm_r(tmp_directory, force: true)
          end
        end
      end
    end
  end
end
