// This code runs inside Figma
// To use: Plugins -> Development -> New Plugin -> Run
// Paste this code in the plugin editor

figma.showUI(__html__, { width: 400, height: 300 });

async function createDesign() {
  const frame = figma.createFrame();
  frame.name = "ProfileView";
  frame.resize(375, 812); // iPhone size
  frame.x = 0;
  frame.y = 0;

  // Set white background
  frame.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];


  const text0 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text0.characters = "John Doe";
  text0.fontSize = 28;
  text0.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text0.x = 20;
  text0.y = 0;
  frame.appendChild(text0);

  const text1 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text1.characters = "iOS Developer & Designer";
  text1.fontSize = 15;
  text1.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text1.x = 20;
  text1.y = 60;
  frame.appendChild(text1);

  const text2 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text2.characters = "128";
  text2.fontSize = 17;
  text2.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text2.x = 20;
  text2.y = 120;
  frame.appendChild(text2);

  const text3 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text3.characters = "Posts";
  text3.fontSize = 12;
  text3.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text3.x = 20;
  text3.y = 180;
  frame.appendChild(text3);

  const text4 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text4.characters = "2.5K";
  text4.fontSize = 17;
  text4.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text4.x = 20;
  text4.y = 240;
  frame.appendChild(text4);

  const text5 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text5.characters = "Followers";
  text5.fontSize = 12;
  text5.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text5.x = 20;
  text5.y = 300;
  frame.appendChild(text5);

  const text6 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text6.characters = "342";
  text6.fontSize = 17;
  text6.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text6.x = 20;
  text6.y = 360;
  frame.appendChild(text6);

  const text7 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text7.characters = "Following";
  text7.fontSize = 12;
  text7.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text7.x = 20;
  text7.y = 420;
  frame.appendChild(text7);

  const text8 = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  text8.characters = "Edit Profile";
  text8.fontSize = 17;
  text8.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  text8.x = 20;
  text8.y = 480;
  frame.appendChild(text8);

  const frame9 = figma.createFrame();
  frame9.resize(120, 44);
  frame9.x = 20;
  frame9.y = 540;
  frame.appendChild(frame9);

  const frame10 = figma.createFrame();
  frame10.resize(200, 200);
  frame10.x = 20;
  frame10.y = 600;
  frame.appendChild(frame10);

  const frame11 = figma.createFrame();
  frame11.resize(200, 200);
  frame11.x = 20;
  frame11.y = 660;
  frame.appendChild(frame11);

  const rect12 = figma.createRectangle();
  rect12.resize(120.0, 120.0);
  rect12.fills = [{
    type: 'SOLID',
    color: { r: 0.5, g: 0.5, b: 0.5 }
  }];
  rect12.cornerRadius = 50;
  rect12.x = 20;
  rect12.y = 720;
  frame.appendChild(rect12);

  figma.currentPage.appendChild(frame);
  figma.viewport.scrollAndZoomIntoView([frame]);

  figma.ui.postMessage({ type: 'creation-complete' });
}

createDesign();

// Close plugin when done
figma.ui.onmessage = msg => {
  if (msg.type === 'close') {
    figma.closePlugin();
  }
};
