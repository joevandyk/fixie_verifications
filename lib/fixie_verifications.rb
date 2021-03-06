module Fixie
  module Verifications
    def self.included base 
      base.extend ClassMethods
      base.class_eval do
        include InstanceMethods
      end
    end

    module ClassMethods
      def has_verification_number options={} 
        has_many :verifications, :class_name => "Fixie::Verifications::Verification", :as => :relation
      end
    end

    module InstanceMethods
      def verified?
        !self.verifications.verified.empty?
      end

      def needs_verification! email
        v = Fixie::Verifications::Verification.create! :relation => self, :email => email
      end

      def verify! code
        Fixie::Verifications::Verification.verify! code
      end
    end

    class Verification < ActiveRecord::Base
      set_table_name :fixie_verifications

      belongs_to :relation, :polymorphic => true

      named_scope :verified, :conditions => "verified_at is not null"

      before_validation_on_create :generate_verification_code
      after_create  :send_email

      validates_presence_of :relation
      validates_presence_of :email
      validates_presence_of :code

      def self.verify! code
        if verification = Verification.find(:first, :conditions => {:code => code})
          verification.verified_at = Time.zone.now
          verification.save!
        end
      end

      private

      def generate_verification_code
        self.code = SecureRandom.hex(15)
      end

      def send_email
        VerificationEmail.deliver_mail(self, email)
      end
    end

    class VerificationEmail < ActionMailer::Base
      self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
      @@from_address = "from@example.com"
      cattr_accessor :from_address

      def mail v, email
        recipients email
        from from_address
        subject "Your verification is needed."
        body :code => v.code
      end
    end
  end
end
