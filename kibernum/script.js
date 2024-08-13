//add your api here below
var API_ENDPOINT = "Paste endpoint URL"
//AJAX GET REQUEST
document.getElementById("saveprofile").onclick = function(){
  var inputData = {
    "Id":$('#id').val(),
      "Nombre":$('#pname').val(),    
        "Cantidad":$('#pcantidad').val()
      };
  $.ajax({
        url: API_ENDPOINT,
        type: 'POST',
        data:  JSON.stringify(inputData)  ,
        contentType: 'application/json; charset=utf-8',
        success: function (response) {
          document.getElementById("profileSaved").innerHTML = "Profile Saved!";
        },
        error: function () {
            alert("error");
        }
    });
}
//AJAX GET REQUEST
document.getElementById("getprofile").onclick = function(){  
  $.ajax({
        url: API_ENDPOINT,
        type: 'GET',
         contentType: 'application/json; charset=utf-8',
        success: function (response) {
          $('#productosPerfil tr').slice(1).remove();
          jQuery.each(response, function(i,data) {          
            $("#productosPerfil").append("<tr> \
                <td>" + data['Id'] + "</td> \
                <td>" + data['Nombre'] + "</td> \
                <td>" + data['Cantidad'] + "</td> \
                </tr>");
          });
        },
        error: function () {
            alert("error");
        }
    });
}