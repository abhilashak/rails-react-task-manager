RSpec.describe "API V1 Registration", type: :request do
  describe "POST /api/v1/register" do
    let(:request_body){
      {
        "user": {
          "email": "test@example.com",
          "password": "password@1",
          "password_confirmation": "password@1"
        }
      }
    }
    let(:request_response) {
      {"data":{"id":1,"email":"test@example.com"},"status":"created"}
    }
    let(:duplicate_email_response) {
      {"errors":["Email has already been taken"],"status":"unprocessable_entity"}
    }
    let(:missing_email_response) {
      {"errors":["Email can't be blank"],"status":"unprocessable_entity"}
    }
    let(:missing_password_response) {
      {"errors":["Password can't be blank","Password digest can't be blank"],"status":"unprocessable_entity"}
    }

    it "valid registration" do
      post "/api/v1/register", params: request_body

      expect(response).to eq(request_reponse)
    end

    it "duplicate email" do
      post "/api/v1/register", params: request_body
      expect(response).to eq(request_reponse)
      
      post "/api/v1/register", params: request_body
      expect(response).to eq(duplicate_email_response)
    end
    
    it "missing email" do
      post "/api/v1/register", params: request_body.merge("email": nil)
      expect(response).to eq(missing_email_response)
    end
    it "missing password" do
      post "/api/v1/register", params: request_body.merge("password": nil)
      expect(response).to eq(missing_password_response)
    end
    it "Malicious mass-assignment attributes" do
      attacker_digest = SecureRandom.hex(32)
      post "/api/v1/register", params: request_body.merge("password_digest": attacker_digest)
      expect(User.last.password_digest).not_to eq(attacker_digest)
    end
  end
end