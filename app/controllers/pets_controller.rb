class PetsController < ApplicationController

  get '/pets' do
    @pets = Pet.all
    erb :'/pets/index' 
  end

  get '/pets/new' do
    @owners = Owner.all 
    erb :'/pets/new'
  end

  post '/pets' do
    @pet = Pet.create(params[:pet])
    if !params["owner"]["name"].empty?
      @owner = Owner.create(name: params["owner"]["name"])
      @pet.owner_id = @owner.id
      @owner.pets << @pet
      @pet.save
      @owner.save
    end
    if !params["pet"]["owner_id"].to_s.empty?
      @owner = Owner.find_by_id(params["pet"]["owner_id"])
      @pet.owner_id = @owner.id
      @pet.save
    end 
    redirect to "pets/#{@pet.id}"
  end

  get '/pets/:id/edit' do 
    @pet = Pet.find_by_id(params[:id])
    @owners = Owner.all
    erb :'/pets/edit'
  end

  get '/pets/:id' do 
    @pet = Pet.find_by_id(params[:id])
    erb :'/pets/show'
  end

  patch '/pets/:id' do
    ####### bug fix
    if !params[:pet].keys.include?("owner_id")
      params[:pet]["owner_id"] = []
    end
      #######
  
      @pet = Pet.find_by_id(params[:id])
      @pet.update(params["pet"])
      if params["owner"]["name"].empty? && !params["id"].empty? #changing owners from existing to existing
        if params["pet"]["owner_id"] == params["id"]
          @pet.save
        else
          old_owner = Owner.find_by_id(params["id"])
            if old_owner
              old_owner.pets.each do |pet|
                if pet == @pet.name 
                  old_owner.pets.delete(pet)
                  old_owner.save
                end
              end
            end
          end
      
      elsif !params["owner"]["name"].empty? && !params["id"].empty? #changing owner to new from existing
        @owner = Owner.create(name: params["owner"]["name"])
        @pet.owner_id = @owner.id
        @owner.pets << @pet
        @pet.save
        @owner.save
        old_owner = Owner.find_by_id(params["id"])
        if old_owner
          old_owner.pets.each do |pet|
            if pet == @pet.name 
              old_owner.pets.delete(pet)
              old_owner.save
            end
          end
        end
      
      elsif !params["owner"]["name"].empty? && params["id"].empty? #creating new owner
        if @owner = Owner.find_by_id(params["owner"]["id"])
          @pet.owner_id = @owner.id
          @owner.pets << @pet
          @pet.save
          @owner.save
        else
          @owner = Owner.create(name: params["owner"]["name"])
          @pet.owner_id = @owner.id
          @owner.pets << @pet
          @pet.save
          @owner.save
        end
      end
    redirect to "pets/#{@pet.id}"
  end
end


# elsif !params["id"].to_s.empty?
      #   @owner = Owner.find_by_id(params["id"])
      #   @pet.owner_id = @owner.id
      #   @pet.save
      