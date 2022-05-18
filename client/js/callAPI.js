//Set fake values for the APYs without the API call
$( document ).ready(function() {
  // $("#rocketpool-apy").text("4.06");
  // $("#lido-apy").text("3.77");
  // $("#stakewise-apy").text("4.0");
  // $("#ankr-apy").text("5.03");
  // let ourAPY = (4.06 + 3.77 + 4.0 + 5.03 )/4;
  // console.log(ourAPY)
  // $("#our-apy").text(String(ourAPY) + "%");
});

//jQuery API call to get yield values
$.get( "https://selenium-scrape-results2.s3.amazonaws.com/outputs/output.json", function( data, status ) {
    console.log(String(data));
    const obj = JSON.parse(data);

    const rpl = parseFloat(obj["RocketPool"]);
    const lido = parseFloat(obj["Lido"]);
    const swise = parseFloat(obj["Stakewise"]);
    const ankr = parseFloat(obj["Ankr"]);

     $("#rocketpool-apy").text(String(rpl) + "%");
     $("#lido-apy").text(String(lido) + "%");
     $("#stakewise-apy").text(String(swise) + "%");
     $("#ankr-apy").text(String(ankr) + "%");

     const ourAPY = ((rpl + lido + swise + ankr)/4).toFixed(2);
     console.log(ourAPY);
     $("#our-apy").text(String(ourAPY) + "%");

    // alert( "Load was performed." + status);
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
