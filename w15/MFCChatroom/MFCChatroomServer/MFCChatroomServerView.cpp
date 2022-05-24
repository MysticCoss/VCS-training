
// MFCChatroomServerView.cpp : implementation of the CMFCChatroomServerView class
//

#include "pch.h"
#include "framework.h"
// SHARED_HANDLERS can be defined in an ATL project implementing preview, thumbnail
// and search filter handlers and allows sharing of document code with that project.
#ifndef SHARED_HANDLERS
#include "MFCChatroomServer.h"
#endif

#include "MFCChatroomServerDoc.h"
#include "MFCChatroomServerView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMFCChatroomServerView

IMPLEMENT_DYNCREATE(CMFCChatroomServerView, CView)

BEGIN_MESSAGE_MAP(CMFCChatroomServerView, CView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, &CMFCChatroomServerView::OnFilePrintPreview)
	ON_WM_CONTEXTMENU()
	ON_WM_RBUTTONUP()
END_MESSAGE_MAP()

// CMFCChatroomServerView construction/destruction

CMFCChatroomServerView::CMFCChatroomServerView() noexcept
{
	// TODO: add construction code here

}

CMFCChatroomServerView::~CMFCChatroomServerView()
{
}

BOOL CMFCChatroomServerView::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

// CMFCChatroomServerView drawing

void CMFCChatroomServerView::OnDraw(CDC* /*pDC*/)
{
	CMFCChatroomServerDoc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	// TODO: add draw code for native data here
}


// CMFCChatroomServerView printing


void CMFCChatroomServerView::OnFilePrintPreview()
{
#ifndef SHARED_HANDLERS
	AFXPrintPreview(this);
#endif
}

BOOL CMFCChatroomServerView::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CMFCChatroomServerView::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CMFCChatroomServerView::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}

void CMFCChatroomServerView::OnRButtonUp(UINT /* nFlags */, CPoint point)
{
	ClientToScreen(&point);
	OnContextMenu(this, point);
}

void CMFCChatroomServerView::OnContextMenu(CWnd* /* pWnd */, CPoint point)
{
#ifndef SHARED_HANDLERS
	theApp.GetContextMenuManager()->ShowPopupMenu(IDR_POPUP_EDIT, point.x, point.y, this, TRUE);
#endif
}


// CMFCChatroomServerView diagnostics

#ifdef _DEBUG
void CMFCChatroomServerView::AssertValid() const
{
	CView::AssertValid();
}

void CMFCChatroomServerView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CMFCChatroomServerDoc* CMFCChatroomServerView::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CMFCChatroomServerDoc)));
	return (CMFCChatroomServerDoc*)m_pDocument;
}
#endif //_DEBUG


// CMFCChatroomServerView message handlers
