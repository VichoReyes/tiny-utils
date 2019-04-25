package main

import (
	"log"
	"os"

	"golang.org/x/net/html"
)

func main() {
	// without any arguments, gets input from stdin and outputs to stdout
	// with one, that's where it gets input from
	// with two, they are input and output respectively

	input := os.Stdin
	output := os.Stdout
	var err error
	log.SetFlags(0)
	log.SetPrefix(os.Args[0] + ": ")
	if len(os.Args) >= 2 {
		input, err = os.Open(os.Args[1])
		if err != nil {
			log.Fatal(err)
		}
	}
	if len(os.Args) >= 3 {
		output, err = os.Create(os.Args[2])
		if err != nil {
			log.Fatal(err)
		}
	}

	doc, err := html.Parse(input)
	if err != nil {
		log.Fatalf("input error: %v\n", err)
	}

	clean(doc, "color:rgba(0,0,0,1);")

	err = html.Render(output, doc)
	if err != nil {
		log.Fatalf("output error: %v\n", err)
	}
}

func clean(n *html.Node, style string) {
	if n.Type == html.ElementNode {

		var reducedAttr []html.Attribute
		for _, a := range n.Attr {
			if a.Key == "style" && a.Val != style {
				// update style for next stuffs
				style = a.Val
				reducedAttr = append(reducedAttr, a)
			} else if a.Key != "style" {
				// keep it, it may be useful
				reducedAttr = append(reducedAttr, a)
			}
		}
		n.Attr = reducedAttr

		if n.Data == "span" && len(reducedAttr) == 0 {
			// n is the definition of a pointless node
			removeKeepChildren(n, style)
			return
		}
	}
	for c := n.FirstChild; c != nil; {
		ns := c.NextSibling
		clean(c, style)
		c = ns
	}
}

func removeKeepChildren(n *html.Node, style string) {
	p := n.Parent
	for c := n.FirstChild; c != nil; {
		ns := c.NextSibling
		c.Parent = nil
		c.PrevSibling = nil
		c.NextSibling = nil
		p.InsertBefore(c, n)
		clean(c, style)
		c = ns
	}
	p.RemoveChild(n)
}
