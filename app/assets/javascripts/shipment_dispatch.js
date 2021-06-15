//Override backbone view of saving the tracking - Send dispatch details as well
ShipmentEditView.prototype.saveTracking = function(e) {
	console.log(e);
    e.preventDefault();
    var tracking = this.$('input#tracking').val(),
        dispatch = this.$('input#dispatch').val();
    var _this = this;
    updateShipment(this.shipment_number, {
      tracking: tracking,
      dispatch: dispatch //Send dispatch value on edit
    }).done(function (data) {
      _this.$('tr.edit-tracking').toggle();

      var show = _this.$('tr.show-tracking');
      show.toggle()
          .find('.tracking-value')
          .html($("<strong>")
          .html(Spree.translations.tracking + ": "))
          .append(document.createTextNode(data.tracking));

        //Update dispatch value 
      show.find('.dispatch-value')
          .html($("<strong>")
          .html("Dispatch: "))
          .append(document.createTextNode(data.dispatch));
    });
  }