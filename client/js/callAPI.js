//Set fake values for the APYs without the API call
$( document ).ready(function() {
  $("#rocketpool-apy").text("4.06");
  $("#lido-apy").text("3.77");
  $("#stakewise-apy").text("4.0");
  $("#ankr-apy").text("5.03");
  let ourAPY = (4.06 + 3.77 + 4.0 + 5.03 )/4;
  console.log(ourAPY)
  $("#our-apy").text(ourAPY);
});

//jQuery API call to get yield values
$.get( "https://selenium-scrape-results2.s3.amazonaws.com/outputs/output.json", function( data ) {
    console.log(data)
     $("#rocketpool-apy").text(data.rocketpool);
     $("#lido-apy").text(data.lido);
     $("#stakewise-apy").text(data.stakewise);
     $("#ankr-apy").text(data.ankr);

     let ourAPY = (4.06 + 3.77 + 4.0 + 5.03 )/4;
     console.log(ourAPY)
     $("#our-apy").text(ourAPY);

    alert( "Load was performed." );
  });


$('.nav-link, .get-started-button').on('click', function (e) {
    e.preventDefault()
    console.log($(this).attr('href'))
  
    $('html, body').animate(
      {
        scrollTop: $($(this).attr('href')).offset().top -110,
      },
      500,
      'linear'
    )
  })

function copyToClipboard(element) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(element).text()).select();
    document.execCommand("copy");
    $temp.remove();
}
